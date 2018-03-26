local luaunit = require("luaunit")
local xmlua = require("xmlua")

TestElement = {}

function TestElement.test_to_html()
  local document = xmlua.XML.parse([[
<html>
  <head>
    <title>Title</title>
  </head>
</html>
]])
  local node_set = document:search("//title")
  luaunit.assertEquals(node_set[1]:to_html(),
                       "<title>Title</title>")
end

function TestElement.test_to_xml()
  local document = xmlua.XML.parse([[<root/>]])
  local node_set = document:search("/root")
  luaunit.assertEquals(node_set[1]:to_xml(),
                       "<root/>")
end

function TestElement.test_previous()
  local document = xmlua.XML.parse([[<root><child1/><child2/></root>]])
  local child2 = document:search("/root/child2")[1]
  luaunit.assertEquals(child2:previous():name(),
                       "child1")
end

function TestElement.test_previous_first()
  local document = xmlua.XML.parse([[<root><child1/><child2/></root>]])
  local child1 = document:search("/root/child1")[1]
  luaunit.assertNil(child1:previous())
end

function TestElement.test_next()
  local document = xmlua.XML.parse([[<root><child1/><child2/></root>]])
  local child1 = document:search("/root/child1")[1]
  luaunit.assertEquals(child1:next():name(),
                       "child2")
end

function TestElement.test_next_last()
  local document = xmlua.XML.parse([[<root><child1/><child2/></root>]])
  local child2 = document:search("/root/child2")[1]
  luaunit.assertNil(child2:next())
end

function TestElement.test_parent()
  local document = xmlua.XML.parse([[<root><child/></root>]])
  local child = document:search("/root/child")[1]
  luaunit.assertEquals(child:parent():name(),
                       "root")
end

function TestElement.test_parent_root()
  local document = xmlua.XML.parse([[<root><child/></root>]])
  local root = document:root()
  luaunit.assertEquals(root:parent():to_xml(),
                       [[
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <child/>
</root>
]])
end

function TestElement.test_children()
  local document = xmlua.XML.parse([[
<root>
  text1
  <child1/>
  text2
  <child2/>
  text3
</root>
]])
  local root = document:root()
  luaunit.assertEquals(root:children():to_xml(),
                       "<child1/><child2/>")
end

function TestElement.test_content()
  local document = xmlua.XML.parse([[
<root>
  text1
  <child1>text1-1</child1>
  text2
  <child2>text2-1</child2>
  text3
</root>
]])
  local root = document:root()
  luaunit.assertEquals(root:content(),
                       [[

  text1
  text1-1
  text2
  text2-1
  text3
]])
end

function TestElement.test_text()
  local document = xmlua.XML.parse([[
<root>
  text1
  <child1>text1-1</child1>
  text2
  <child2>text2-1</child2>
  text3
</root>
]])
  local root = document:root()
  luaunit.assertEquals(root:text(),
                       root:content())
end

function TestElement.test_get_attribute_raw()
  local document = xmlua.XML.parse("<root class=\"A\"/>")
  local node_set = document:search("/root")
  luaunit.assertEquals(node_set[1]:get_attribute("class"),
                       "A")
end

function TestElement.test_get_attribute_property()
  local document = xmlua.XML.parse("<root class=\"A\"/>")
  local node_set = document:search("/root")
  luaunit.assertEquals(node_set[1].class,
                       "A")
end

function TestElement.test_get_attribute_array_referece()
  local document = xmlua.XML.parse("<root class=\"A\"/>")
  local node_set = document:search("/root")
  luaunit.assertEquals(node_set[1]["class"],
                       "A")
end

function TestElement.test_set_attribute_raw()
  local document = xmlua.XML.parse("<root/>")
  local root = document:root()
  root:set_attribute("class", "A")
  luaunit.assertEquals(document:to_xml(),
                       [[
<?xml version="1.0" encoding="UTF-8"?>
<root class="A"/>
]])
end

function TestElement.test_set_attribute_substitution()
  local document = xmlua.XML.parse("<root/>")
  local root = document:root()
  root.class = "A"
  luaunit.assertEquals(document:to_xml(),
                       [[
<?xml version="1.0" encoding="UTF-8"?>
<root class="A"/>
]])
end

function TestElement.test_set_attribute_with_namespace()
  local xml = [[
<?xml version="1.0" encoding="UTF-8"?>
<xhtml:html xmlns:xhtml="http://www.w3.org/1999/xhtml"/>
]]
  local document = xmlua.XML.parse(xml)
  local root = document:root()
  root:set_attribute("xhtml:class", "top-level")
  luaunit.assertEquals(document:to_xml(),
                       [[
<?xml version="1.0" encoding="UTF-8"?>
<xhtml:html xmlns:xhtml="http://www.w3.org/1999/xhtml" xhtml:class="top-level"/>
]])
end

function TestElement.test_path()
  local document = xmlua.XML.parse("<root/>")
  local root = document:root()
  luaunit.assertEquals(root:path(),
                       "/root")
end

function TestElement.test_unlink()
  local document = xmlua.XML.parse([[<root><child/></root>]])
  local root = document:root()
  local child = root:children()[1]
  child:unlink()
  luaunit.assertEquals(document:to_xml(),
                       [[
<?xml version="1.0" encoding="UTF-8"?>
<root/>
]])
end
