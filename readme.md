

MoonXML
========

MoonXML is a library that allows using MoonScript as a DSL to generate XML or HTML.
It works in a similar fashion to the Lapis builder syntax.

Here’s a quick example:

```moon
moonxml = require "moonxml"

render = (f) -> moonxml.xml(f) io.write

render ->
	svg ->
		rect x: 5, y: 5, width: 90, height: 90
```

Which should generate the following code:

```xml
<svg>
<rect y="5" x="5" width="90" height="90"/>
</svg>
```

Using the `strbuffer` rock
-----

The following code produces the same output as above, but uses the `strbuffer` rock to store the generated content before printing it.

```moon
buffer = require("strbuffer")('\n')
moonxml = require "moonxml"

render = (fnc) -> moonxml.xml(fnc)(buffer\append)

render ->
	svg ->
		rect
			x: 5
			y: 5
			width: 90
			height: 90
print buffer
```

The `strbuffer` rock can be found [here](//github.com/darkwiiplayer/lua_strbuffer).

Usage
-----

TODO: Write :P

### Special functions

#### `print`

`print` can be used within moonxml function to add raw text to the output IO.

The text that is output is not escaped and could result in invalid documents.
See also `escape`.

What's more, print is actually the function passed to the template when using it, so it may do all kinds of things, like adding its arguments to a buffer or even sending them to a client.
A more precise way to think of it may be that it adds its argument to the output stream, whatever that may be.

Example:

```moon
render ->
	print "this<br/>is</br>multiline"
```

Will print:

```html
this<br/>is<br/>multiline
```

#### `escape`

Escapes special characters to HTML sequences.

Examples:

`escape '<html>'` produces `&lt;html&gt;`

`escape '3 < 42'` produces `3 &lt; 42`

#### `html5`

`html5` adds a HTML5 DOCTYPE to the document when called.
Be careful to always call it at the beginning of the document, as the DOCTYPE is added where `html5` is called!

### Defining new tags

```moon
with moonxml.environment.xml
	.xml = ->
		.print "<?xml version=\"1.0\"?>\n"
```

TODO: Write :P

Warning(s)
-----

Because of how lua works, once a function is passed into `render` or `build`, its upvalues are permanently changed.
This means functions may become otherwise unusable, and shouldn't be used for more than one template at the same time.
Seriously, things might explode and kittens may die.

It also seems like in lua 5.2+ the environment isn't necessarily the first upvalue (?) so things break if any upvalue is accessed before any global.
This will be less of a problem once a proper way to load entire files in the builder environment exists.

Compatibility with Lapis
-----

MoonXML is **NOT** a clone of the Lapis generator syntax.
Although most short snippets will work, more complex constructs may require some adaptation.

MoonXML flattening its arguments also means that you can do a lot more "weird stuff" with it that just wouldn't work in lapis, so be aware of that.

FengariXML
-----

I'm not sure if this should be its own project or not, but all of this code can easily be ported to generate HTML nodes directly in the browser using [Fengari](//github.com/fengari-lua/fengari), and I will probably build something like that sooner or later.

Changelog
-----

### 2.0.0

- MoonXML now also does HTML, making MoonHTML obsolete. This change was necessary because both projects shared most of their code and only differed in how they treat empty tags.
- Render functions are gone (they were one-liners, so the user can build them when needed) to reduce feature bloat
- There are no more individual environments generated on the fly, but instead, there's just a single environment containing all the XML functions

### 1.1.0

- MoonXML doesn't have any concept of buffers anymore, instead you pass it a function that handles your output (see examples)
- The pair method is gone, and instead there is emv, which only returns an environment
- build now returns a function, which in turn accepts as its first argument a function that handles output. All aditional arguments are passed to the function provided by the user

Note that I initially intended to use this mainly inside [Vim](//vim.sourceforge.io/), where I have a macro set up to feed the visual selection through the moonscript interpreter and replace it with its output. It has also grown to the point where it can perfectly be used within a web server like openresty or pegasus, or in other more high-level code like my [multitone](//github.com/darkwiiplayer/multitone) function. I can also imagine a document markup DSL with some aditional abstractions (like using `title` instead of `h1`..`h6`, etc.)

License
-----

License: [The Unlicense](//unlicense.org)
