
// Function : compare_items
// Compares AXI write and read transactions to verify memory readback behavior
// Supports FIXED, INCR, and WRAP burst types
function bit axi_seq::compare_items(ref axi_seq_item write_item, ref axi_seq_item read_item);

  // Local variables
  bit [7:0] local_buffer[];           // Circular buffer for FIXED burst
  bit [7:0] expected_data_array[];    // Expected data for comparison
  bit [7:0] expected_data, read_data;
  int       miscompare_count = 0;
  int       beat_size = 2 ** write_item.burst_size;

  // Strings for debug output
  string wr_str      = "";
  string rd_str      = "";
  string exp_str     = "";
  string buf_str     = "";

  // FIXED Burst: repeated beat pattern, circular behavior
  if (write_item.burst_type == e_FIXED) begin

    // Initialize local buffer
    local_buffer = new[beat_size];
    foreach (local_buffer[i]) local_buffer[i] = 8'h00;

    // Fill local buffer in a circular way from write data
    int buf_idx = 0;
    foreach (write_item.data[i]) begin
      local_buffer[buf_idx++] = write_item.data[i];
      if (buf_idx >= beat_size) buf_idx = 0;
    end

    // Build expected readback pattern using repeated local buffer
    expected_data_array = new[read_item.data.size()];
    buf_idx = 0;
    foreach (expected_data_array[i]) begin
      expected_data_array[i] = local_buffer[buf_idx++];
      if (buf_idx >= beat_size) buf_idx = 0;
    end

    // Compare expected vs actual read data
    foreach (read_item.data[i]) begin
      if (expected_data_array[i] != read_item.data[i]) begin
        miscompare_count++;
      end
    end

    // Print mismatch debug info
    if (miscompare_count != 0) begin
      foreach (write_item.data[i])         $sformat(wr_str, "%s 0x%02x", wr_str, write_item.data[i]);
      foreach (read_item.data[i])          $sformat(rd_str, "%s 0x%02x", rd_str, read_item.data[i]);
      foreach (expected_data_array[i])     $sformat(exp_str, "%s 0x%02x", exp_str, expected_data_array[i]);
      foreach (local_buffer[i])            $sformat(buf_str, "%s 0x%02x", buf_str, local_buffer[i]);

      `uvm_error("AXI READBACK e_FIXED miscompare",
        $sformatf("%0d miscompares:\nExpected: %s\nActual:   %s\nWritten:  %s\nBuffer:   %s",
                  miscompare_count, exp_str, rd_str, wr_str, buf_str))
    end

  end

  // INCR or WRAP Burst: direct byte-by-byte comparison
  else if (write_item.burst_type == e_INCR || write_item.burst_type == e_WRAP) begin
    foreach (write_item.data[i]) begin
      expected_data = write_item.data[i];
      read_data     = read_item.data[i];

      if (expected_data != read_data) begin
        miscompare_count++;
        `uvm_error("AXI READBACK INCR/WRAP miscompare",
          $sformatf("Index %0d: expected = 0x%02x, actual = 0x%02x",
                    i, expected_data, read_data))
      end
    end
  end

  // Unsupported burst type
  else begin
    miscompare_count++;
    `uvm_error(this.get_type_name(),
      $sformatf("Unsupported burst type: %0d", write_item.burst_type))
  end

  // Return comparison result
  return (miscompare_count == 0);

endfunction : compare_items
