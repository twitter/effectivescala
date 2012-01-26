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

table#toc {
	margin: 0 auto;
}

/* XXX: apply only to TOC. todo: reapply -- html whatever? */   
ul {
/*	list-style-type: none;*/
}

</style>

<h1 class="header">Effective Scala</h1>
<address>Marius Eriksen, Twitter Inc.<br />marius@twitter.com</address>

<h2>Table of Contents</h2>

.toc
 
## Introduction

[Scala] [][#Odersky:2004] is one of the chief application programming
languages used at Twitter. Much of our infrastructure is written in
Scala and we have several large libraries[^libs] supporting it. While
highly effective, Scala is also a large language, and experience has
taught us to practice great care in its application. This guide
attempts to distill this experience into short essays, providing a
guide of *best practices*. Our experience is in creating high volume
services that form distributed systems (and our advice is thus
biased), but most of the advice herein should translate naturally to
other domains. This is not the law, but deviation should be well
justified.

Scala provides many tools that enable succinct expression. Less typing
is less reading, and less reading is often faster reading, and thus
brevity enhances clarity. However brevity is a blunt tool that can
also deliver the opposite effect: After correctness, think always of
the reader.

Note that this is not an introduction to Scala. We assume the reader
is familiar with the language. Some resources for learning Scala are:

* [Scala School](http://twitter.github.com/scala_school/)
* [Learning Scala](http://www.scala-lang.org/node/1305)
* [Learning Scala in Small Bites](http://matt.might.net/articles/learning-scala-in-small-bites/)

## Formatting

The specifics of code *formatting* - so long as they are practical -
are of little consequence. By definition style cannot be inherently
good or bad, and in our experience almost everybody differs in
preferences. *Consistent* application of style, however, enhances
readability. A reader already familiar with a particular style does
not have to grasp yet another set of local conventions, or decipher
yet another corner of the language grammar.

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
length. Use one blank line between method, class, and object definitions.

### Naming

<dl class="rules">
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
<dt>Avoid using <code>`</code>s to overload reserved names.</dt>
<dd><code>typ</code> instead of <code>`type</code>`</dd>
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

<dl class="rules">
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
import concurrent</code></pre> in favor of the unambiguous <pre><code>import com.twitter.concurrent</code></pre></dd>
<dt>Put imports at the top of the file</dt>
<dd>The reader can refer to all imports in one place.</dd>
</dl>

### Implicits

Implicits are a powerful language feature, but they should be used
sparingly. They have complicated resolution rules and make it
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
	 
.< but <em>not</em> the standard ScalaDoc style:

	/** ServiceBuilder builds services
	 * ...
	 */

Do not resort to ASCII art or other visual embellishments. Document
APIs but do not add unecessary comments. If you find yourself adding
comments to explain the behavior of your code, ask first if it can be
restructured so that it becomes obvious what it does. Prefer
"obviously it works" to "it works, obviously" (with apologies to Hoare).

## Types and Generics

The primary objective of a type system is to detect programming
errors. The type system effectively provides a limited form of static
verification, allowing us to express certain kinds of invariants about
our code that the compiler can verify. Type systems provide other
benefits too of course, but error checking is by far the greatest.

Our use of the type system should reflect this goal, but we must
remain mindful of the reader: judicious use of types can serve to
enhance clarity, being unduly clever only obfuscates.

Scala's powerful type system is a common source of academic
exploration and exercise (eg. [Type level programming in
Scala](http://apocalisp.wordpress.com/2010/06/08/type-level-programming-in-scala/)).
While a fascinating academic topic, these techniques rarely find
useful application in production code. They are to be avoided.

### Return type annotations

While Scala allows these to be omitted, such annotations provide good
documentation: this is especially important for public methods. Where a
method is not exposed and its return type obvious, omit them.

This is especially important when instantiating objects with mixins as
the scala compiler creates singleton types for these. For example, `make`
in:

	trait Service
	def make() = new Service{}

.< does <em>not</em> have a return type of <code>Service</code>. This is achieved with an explicit annotation:

	def make(): Service = new Service{}

Now the author is free to mix in more traits without changing the
public type of `make`, making it easier to manage backwards
compatibility.

### Variance

Variance arises when generics are combined with subtyping. They define
how subtyping of the *contained* type relate to subtyping of the
*container* type. Because Scala has declaration site variance
annotations, authors of common libraries -- especially collections --
must be prolific annotators. Such annotations are important for the
usability of shared code, but misapplication can be dangerous.

*Immutable collections should be covariant*. Methods that receive
the contained type should "downgrade" the collection appropriately:

	trait Collection[+T] {
	  def add[U >: T](other: U): Collection[U]
	}

*Mutable collections should be invariant*. Covariance
is typically invalid with mutable collections. Consider

	trait HashSet[+T] {
	  def add[U >: T](item: U)
	}

.< and the following type hierarchy:

	trait Mammal
	trait Dog extends Mammal
	trait Cat extends Mammal

.< If I now have a hash set of dogs

	val dogs: HashSet[Dog]

.< treat it as a set of Mammals and add a cat.

	val mammals: HashSet[Mammal] = dogs
	mammals.add(new Cat{})

.< This is no longer a HashSet of dogs!

<!--
  *	when to use abstract type members?
-->

### Type aliases

Use type aliases when they provide convenient naming or clarify
purpose, but do not alias types that are self-explanatory.

	() => Int

.< is clearer than

	type IntMaker = () => Int
	IntMaker

.< since it is both short and uses a common type. However

	class ConcurrentPool[K, V] {
	  type Queue = ConcurrentLinkedQueue[V]
	  type Map   = ConcurrentHashMap[K, Queue]
	  ...
	}

.< is helpful since it communicates purpose and enhances brevity.

Don't use subclassing when an alias will do.

	trait SocketFactory extends (SocketAddress) => Socket
	
.< a <code>SocketFactory</code> <em>is</em> a function that produces a <code>Socket</code>. Using a trait here makes it impossible use a function literal to provide a <code>SockeFactory</code>. If a trait is introduced because it allows a toplevel name, use a package object instead.

	package com.twitter
	package object net {
	  type SocketFactory = (SocketAddress) => Socket
	}

## Collections

Use the simplest collection that meets your needs.

when receiving: the most general, don't receive List[] when you mean Seq[]


<!--

use Seq[] for ordered sequential data.

Ordering.


-->

## Concurrency

Modern services are highly concurrent -- it is common for servers to
coordinate 10s-100s of thousands of simultaneous operations -- and
handling the implied complexity is a central theme in authoring robust
systems software.

*Threads* provide a means of expressing concurrency: they give you
independent, heap-sharing execution contexts that are scheduled by the
operating system. However, thread creation is expensive in Java and is
a resource that must be managed, typically with the use of pools. This
creates additional complexity for the programmer, and also a high
degree of coupling: it's difficult to divorce application logic from
their use of the underlying resources.

This complexity is especially apparent when creating services that
have a high degree of fan-out: each incoming request results in a
multitude of requests to yet another tier of systems. In these
systems, thread pools must be managed so that they are balanced
according to the ratios of requests in each tier: mismanagement of one
thread pool bleeds into another.

Robust systems must also consider timeouts and cancellation, both of
which require the introduction of yet more "control" threads,
complicating the problem further. Note that if threads were cheap
these problems would be diminished: no pooling would be required,
timed out threads could be discarded, and no additional resource
management would be required.

### Futures

Use Futures[^futures] to manage concurrency. They decouple
concurrent operations from resource management: for example, [Finagle]
multiplexes concurrent operations onto few threads in an efficient
manner. Scala has lightweight closure literal syntax, so Futures
introduce little syntactic overhead, and they become second nature to
most programmers.

Futures allow the programmer to express concurrent computation in a
declarative style, are composable, and have principled handling of
failure. These qualities has convinced us that they are especially
well suited for use in functional programming languages, where this is
the encouraged style.

*Prefer "data transformation" over creating your own futures.* Future
transformations ensure that failures are propagated, that
cancellations are signalled, and frees the programmer from thinking
about the implications of the Java memory model. Even a careful
programmer might write the following to issue an RPC 10 times in
sequence and then print the results:

	val p = new Promise[List[Result]]
	var results: List[Result] = Nil
	def collect() {
	  doRpc() onSuccess { result =>
	    results = result :: results
	    if (results.length < 10)
	      collect()
	    else
	      p.setValue(results)
	  } onFailure { t =>
	    p.setException(t)
	  }
	}
	
	p onSuccess { results =>
	  printf("Got results %s\n", results.mkString(", "))
	}

The programmer had to ensure that RPC failures are propagated,
interspersing the code with control flow; worse, the code is wrong!
Without declaring `results` volatile, we cannot ensure that `results`
holds the previous value in each iteration. The Java memory model is a
subtle beast, but luckily we can avoid all of these pitfalls by using
the declarative style:

	def collect(results: List[Result] = Nil): Future[List[Result]] =
	  doRpc() flatMap { result =>
	    if (results.length < 9)
	      collect(result :: results)
	    else
	      result :: results
	  }

	collect() onSuccess { results =>
	  printf("Got results %s\n", results.mkString(", "))
	}

We use `flatMap` to sequence operations and prepend the result onto
the list as we proceed. This is a common functional programming idiom
translated to Futures. This is correct, requires less boilerplate, is
less error prone, and also reads better.

*Use the Future combinators*. `Future.select`, `Future.join`, and
`Future.collect` codify common patterns when operating over
multiple futures that should be combined.

### Collections

Always start with the simplest, most boring, most standard collection that serves
the purpose. Don't reach for a concurrent collection before you *know* that
a synchronized one won't do: the JVM has sophisticated machinery to make
synchronization cheap, so their efficacy may surprise you.

Many concurrent collections have complicated semantics, and make use
of subtler aspects of the Java memory model, so make sure you
understand the implications -- especially with respect to publishing
updates -- before you use them. Synchronized collections also compose
better: operations like `getOrElseUpdate` cannot be implemented
correctly by concurrent collections, and creating composite
collections is especially error prone.

<!--

use the stupid collections first, get fancy only when justified.

serialized? synchronized?

blah blah.

Async*?

-->


## Control flow

Returns are OK!


## Consider the Java programmer


[#Odersky:2004]: Martin Odersky et. al. *An Overview of the Scala
Programming Language*. EPFL Tech report, 2004.

[^libs]: [Finagle] and [Util] are used in nearly all of our systems.

[^futures]: Use the [util implementation](https://github.com/twitter/util/blob/master/util-core/src/main/scala/com/twitter/util/Future.scala).

[Scala]: http://www.scala-lang.org/
[Finagle]: http://github.com/twitter/finagle
[Util]: http://github.com/twitter/util
