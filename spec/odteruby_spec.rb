require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Serenity

  describe OdtEruby do
    before(:each) do
      name = 'test_name'
      type = 'test_type'
      rows = []
      rows << Ship.new('test_name_1', 'test_type_1')
      rows << Ship.new('test_name_2', 'test_type_2')
      @context = binding
    end

    def squeeze text
      text.inject('') { |memo, line| memo += line.strip } unless text.nil?
    end

    it 'should replace variables with values from context' do
      template = <<-EOF
        <text:p text:style-name="Text_1_body">{%= name %}</text:p>
        <text:p text:style-name="Text_1_body">{%= type %}</text:p>
        <text:p text:style-name="Text_1_body"/>
      EOF

      expected = <<-EOF
        <text:p text:style-name="Text_1_body">test_name</text:p>
        <text:p text:style-name="Text_1_body">test_type</text:p>
        <text:p text:style-name="Text_1_body"/>
      EOF

      content = OdtEruby.new(XmlReader.new template)
      result = content.evaluate @context

      squeeze(expected).should == squeeze(result)
    end

    it 'should replace multiple variables on one line' do
      template = '<text:p text:style-name="Text_1_body">{%= type %} and {%= name %}</text:p>'
      expected = '<text:p text:style-name="Text_1_body">test_type and test_name</text:p>'

      content = OdtEruby.new(XmlReader.new template)
      result = content.evaluate @context

      squeeze(expected).should == squeeze(result)
    end
=begin
    should 'replace a LOOP construct with variables' do
      template = <<-EOF
        <text:p text:style-name="Text_1_body">{% for row in rows do %}</text:p>
          <text:p text:style-name="Text_1_body">{%= row.name %}</text:p>
          <text:p text:style-name="Text_1_body">{%= row.type %}</text:p>
        <text:p text:style-name="Text_1_body">{% end %}</text:p>
      EOF

      expected = <<-EOF
          <text:p text:style-name="Text_1_body">test_name_1</text:p>
          <text:p text:style-name="Text_1_body">test_type_1</text:p>
          <text:p text:style-name="Text_1_body">test_name_2</text:p>
          <text:p text:style-name="Text_1_body">test_type_2</text:p>
      EOF

      content = OdtEruby.new(XmlReader.new template)
      result = content.evaluate @context
      assert_equal expected, result
    end
=end

    it 'should remove empty tags after a control structure processing' do
      template = <<-EOF
        <table:table style="Table_1">
          <table:row style="Table_1_A1">
            <table:cell style="Table_1_A1_cell">
              {% for row in rows do %}
            </table:cell>
          </table:row>
            <text:p text:style-name="Text_1_body">{%= row.name %}</text:p>
            <text:p text:style-name="Text_1_body">{%= row.type %}</text:p>
          <table:row style="Table_1_A1">
            <table:cell style="Table_1_A1_cell">
              {% end %}
            </table:cell>
          </table:row>
        </table:table>
      EOF

      expected = <<-EOF
        <table:table style="Table_1">
            <text:p text:style-name="Text_1_body">test_name_1</text:p>
            <text:p text:style-name="Text_1_body">test_type_1</text:p>
            <text:p text:style-name="Text_1_body">test_name_2</text:p>
            <text:p text:style-name="Text_1_body">test_type_2</text:p>
        </table:table>
      EOF

      content = OdtEruby.new(XmlReader.new template)
      result = content.evaluate @context

      squeeze(expected).should == squeeze(result)
    end
  end
end
