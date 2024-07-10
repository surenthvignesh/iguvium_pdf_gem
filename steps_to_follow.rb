


pdf = PDF::Reader.new(path)
@pdf_filename = filename.chomp(".pdf") # Store the PDF filename without extension
lines = []
po_number = nil
# Extract the PDF data using Iguvium gem
@item_code_list, @description_list = get_data_from_iguvium_pages(path)
pdf.pages.each do |page|
  po_number ||= extract_po_number(page.text)
  lines += order_lines(page, @item_code_list)
end


def get_data_from_iguvium_pages(path)
    iguvium_pages = Iguvium.read(path)

    item_code_list = []
    description_list = ''
    iguvium_pages.each do |page|
      table = page.extract_tables! rescue ''
      table_arr = table.map(&:to_a) rescue []
      table_arr.each_with_index do |value, index|
        value.flatten[0].split(' ').each do |item_code|
          next if item_code == "Item"
          item_code.length <= 4 ? item_code_list[-1] = item_code_list[-1] + item_code.strip : item_code_list << item_code
        end

        if value.flatten[2].split(' ')[0] == "Description"
          value.flatten[2].gsub('Description', '') if index > 0
          description_list += value.flatten[2]
        end
      end
    end

    [item_code_list, description_list]
  end
end
