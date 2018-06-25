package = "moonxml"
version = "1.1.0-1"
source = {
   url = "git://github.com/DarkWiiPlayer/moonxml.git";
	 tag = 'v1.1.0'
}
description = {
   homepage = "https://github.com/DarkWiiPlayer/moonxml";
   license = "Unlicense";
}
dependencies = {
  "lua >= 5.1";
}
build = {
   type = "builtin",
   modules = {
     moonxml = 'xml.lua'
   }
}
