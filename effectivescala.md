Title:		Effective Scala
Date:	2012/01/24
Quotes Language: english

<style>
body {
	font-family: times, serif;
	margin: 0 1.0in 0 1.0in;
}


address {
	text-align: center;
}

.header {
	text-align: center;
	margin-top: 1em;
}

.rhs {
	text-align: left;
}

p {
	text-indent: 1em;
	text-align: justify;
}

.unind {
	text-indent: 0em;
}

code {
	font-family: Monaco, 'Courier New', 'DejaVu Sans Mono', 'Bitstream Vera Sans Mono', monospace;
	font-size: 0.75em;
}

h2 {
	font-weight: bold;
	font-size: 110%;
	margin-top: 1.5em;
	margin-bottom: 0.05in;
}

h3 {
	font-size: 100%;
	font-style: oblique;
	margin-top: 1.5em;
	margin-bottom: 0.05in;
}

pre {
	margin: 0 0.5in 0 0.5in;
}

dl.rules dt {
	font-style: oblique;
}

</style>

<link href="prettify.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="prettify.js"></script>

<h1 class="header">Effective Scala</h1>
<address>Marius Eriksen, Twitter Inc.<br />marius@twitter.com</address>

## Introduction

[Scala] [][#Odersky:2004] is one of the chief application programming
languages used at Twitter. Much of our infrastructure is written in
Scala and we have several large libraries[^libs] supporting it. While
highly effective, Scala is also a large language, and experience has
taught us to practice great care in its application. This guide
attempts to distill this experience into short essays, providing a
guide of *best practices*. They are not the law, but deviation
should be well justified.

Scala provides many tools that enable succinct expression. Indeed this
is one of the most attractive aspects of the language. Less typing is
less reading, and less reading is often faster reading: In this way
brevity enhances clarity. However it is a blunt tool that can also
deliver the opposite effect. After correctness, think always of the
reader.

## Formatting

The specifics of code *formatting* - so long as they are practical -
are of little consequence. By definition style cannot be inherently
good or bad, and my experience almost everybody differs in
preferences. *Consistent* application of style, however, enhances
readability. A reader already familiar with a particular style does
not have to grasp yet another set of local conventions.

This is of particular importance to Scala, as its grammar has a high
degree of overlap. One telling example is method invocation: Methods
can be invoked with `.`, with whitespace, without parenthesis for
nullary or unary methods, with parenthesis for these, … Furthermore,
the different styles of method invocations expose different
ambiguities in its grammar! Surely the consistent application of a
carefully chosen set of formatting rules will resolve a great deal of
ambiguity for both man and machine.

We adhere to the [Scala style
guide](http://docs.scala-lang.org/style/) plus the following rules.

### Whitespace

Indent by two spaces. Try to avoid lines greater than 100 columns in
length. Use one blank line between method, class and object definitions.

### Naming

<dl class=rules>
<dt>Use short names for small scopes</dt>
<dd> <code>i</code>s, <code>j</code>s and <code>k</code>s are all but expected
in loops. </dd>
<dt>Use longer names for larger scopes</dt>
<dd>External APIs should have longer and explanatory names that confer meaning.
<code>Future.collect</code> not <code>Future.all</code>.
</dd>
<dt>Use common abbreviations but eschew esoteric ones</dt>
<dd>
Everyone
knows <code>ok</code>, <code>err</code> or <code>defn</code> 
whereas <code>sfri</code> is not so common.
</dd>
<dt>Don't rebind names for different uses</dt>
<dd>Use <code>val</code>s</dd>
<dt>Avoid using <code>`</code>s to use reserved names.</dt>
<dd><code>typ</code> instead of <code>`type`</code></dd>
<dt>Use active names for operations with side effects</dt>
<dd><code>user.activate()</code> not <code>user.setActive()</code></dd>
<dt>Use descriptive names for methods that return values</dt>
<dd><code>src.isDefined</code> not <code>src.defined</code></dd>
<dt>Don't prefix getters with <code>get</code></dt>
<dd>As per the previous rule, it's redundant: <code>site.count</code> not <code>site.getCount</code></dd>
<dt>Don't repeat names that are already encapsulated in package or object name</dt>
<dd>Prefer:
<pre><code>object User {
  def get(id: Int): Option[User]
}</code></pre> to
<pre><code>object User {
  def getUser(id: Int): Option[User]
}</code></pre>They are redundant in use: <code>User.getUser</code> provides
no more information than <code>User.get</code>.
</dd>
</dl>


### Imports

<dl class=rules>
<dt>Sort imports alphabetically</dt>
<dd>This makes it easy to examine visually, and is simple to automate.</dd>
<dt>Use braces when importing several names from a package</dt>
<dd><code>import com.twitter.concurrent.{Offer, Broker}</code></dd>
<dt>Use wildcards when more than six names are imported</dt>
<dd>e.g.: <code>import com.twitter.concurrent._</code>
<br />Don't apply this blindly: some packages export too many names</dd>
<dt>When using collections, qualify names by importing 
<code>scala.collections.immutable</code> and/or <code>scala.collections.mutable</code></dt>
<dd>Mutable and immutable collections have dual names. 
Qualifiying the names makes is obvious to the reader which variant is being used (e.g. "<code>immutable.Map</code>")</dd>
<dt>Do not use relative imports from other packages</dt>
<dd>Avoid <pre><code>import com.twitter
import concurrent</code></pre> in favor of simply <pre><code>import com.twitter.concurrent</code></pre></dd>
<dt>Put imports at the top of the file</dt>
<dd>The reader can refer to all imports in one place.</dd>
</dl>

### Implicits

Implicits are a powerful language feature, but they should be used
sparingly. They have complicated resolution rules and makes it
difficult -- by simple lexical examination -- to see what's actually
happening. It's definitely OK to use implicits in the following
situations:

* Extending or adding a Scala-style collection
* Adapting an object ("pimp my library" pattern)
* Use to *enhance type safety* by providing constraint evidence
* For `Manifest`s

If you do find yourself using implicits, always ask yourself if there is
a way to achieve the same thing without their help.

### Comments

Use [ScalaDoc](https://wiki.scala-lang.org/display/SW/Scaladoc) to
provide API documentation. Use the following style:

	/**
	 * ServiceBuilder builds services 
	 * ...
	 */
	 
.< but *not* the standard ScalaDoc style:

	/** ServiceBuilder builds services
	 * ...
	 */

Do not resort to ASCII art or other visual embellishments. Document
APIs but do not add unecessary comments. If you find yourself adding
comments to explain the behavior of your code, ask first if it can be
restructured so that it becomes obvious what it does. Prefer
"obviously it works" to "it works, obviously" (with apologies to Hoare).

## Types



[#Odersky:2004]: Martin Odersky et. al. *An Overview of the Scala
Programming Language*. EPFL Tech report, 2004.

[^libs]: [Finagle] and [Util] are used in nearly all of our systems.

[^sfri]: Safari, the web browser.

[Scala]: http://www.scala-lang.org/
[Finagle]: http://github.com/twitter/finagle
[Util]: http://github.com/twitter/util
