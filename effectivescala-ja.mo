<a href="http://github.com/twitter/effectivescala"><img style="position: absolute; top: 0; left: 0; border: 0;" src="https://a248.e.akamai.net/assets.github.com/img/edc6dae7a1079163caf7f17c60495bbb6d027c93/687474703a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f6c6566745f677265656e5f3030373230302e706e67" alt="Fork me on GitHub"></a>

<h1 class="header">Effective Scala</h1>
<address>Marius Eriksen, Twitter Inc.<br />marius@twitter.com (<a href="http://twitter.com/marius">@marius</a>)<br /><br />[translated by Yuta Okamoto(<a href="http://github.com/okapies">@okapies</a>) and Satoshi Kobayashi(<a href="https://github.com/scova0731">@scova0731</a>)]</address>

<h2>Table of Contents</h2>

.TOC


<h2>他の言語</h2>
<a href="index.html">English</a>

## 序章

[Scala][Scala]は、Twitterで使われている主なアプリケーションプログラミング言語の一つだ。TwitterのインフラのほとんどはScalaで書かれているし、我々の業務を支える[大規模ライブラリ](http://github.com/twitter/)をいくつか持っている。Scalaは極めて効率的だが、一方で大きな言語でもある。我々の経験上、Scalaの適用には細心の注意が必要だ。Scalaの落とし穴は何か？ どの機能を採用し、どれを避けるべきか？ いつ"純粋関数型スタイル"を用い、いつ控えるべきか？ つまり、我々が見出した"Scalaの効果的(effective)な使い方"とは何か？ このガイドは、我々の経験を抽出し、一連の*ベストプラクティス*を提供する小論文にまとめようとするものだ。Twitterは、Scalaを、主に分散システムを構成する大容量サービスの作成に利用している。だから、我々の助言にはバイアスがかかっている。しかし、ここにあるアドバイスのほとんどは、他の問題領域へも自然に置き換えることができるはずだ。これは法律じゃない、だから逸脱は正当化されるべきだ。

Scalaは、簡潔な表現を可能にする数多くのツールを提供している。タイピングが少なければ、読む量も少なくなり、読む量が少なくなれば、大抵はより早く読める。故に、簡潔さは明瞭さを高める。しかし、簡潔さはまた、正反対の効果をもたらす使い勝手の悪い道具ともなりえる。正確さの次に、いつも読み手のことを考えよう。

何よりも、*Scalaでプログラムするのだ*。君が書いているのはJavaではないし、Haskellでも、Pythonでもない。Scalaのプログラムは、それらのうちのいずれの言語で書かれたものとも違っている。Scalaを効果的に使うには、君の問題をScalaの用語で表現しなければならない。Javaのプログラムを、無理矢理にScalaになおしても仕方がない。ほとんどのやり方で、それはオリジナルより劣ったものになるだろう。

これは、Scalaの入門じゃない。読者は、Scalaに慣れ親しんでいることを前提としている。これからScalaを学びたい人は、以下のサイトを参照するといいだろう:

* [Scala School](http://twitter.github.com/scala_school/)
* [Learning Scala](http://www.scala-lang.org/node/1305)
* [Learning Scala in Small Bites](http://matt.might.net/articles/learning-scala-in-small-bites/)

このガイドは生きたドキュメントであり、現在の「ベストプラクティス」が反映されていく。けれども、核となるアイデアは変わらない。常に可読性を優先せよ。ジェネリックなコードを書き、しかし明瞭さを犠牲にするな。シンプルな言語機能を利用せよ。それは偉大な力を与え、難解さを防ぐ（型システムでは特に）。とりわけ、トレードオフを常に意識すべきだ。洗練された言語は複雑な実装を必要とし、判断や、動作や、機能間の相互作用や、そして君の協力者に対する理解を困難にする。つまり、複雑さは洗練の税金なのだ。効用がコストを上回っていることを、常に確認しなければいけない。

では、楽しんでほしい。

## 書式

コードの*書式*の詳細は（それが実際的である限りは）重要じゃない。当然だが、スタイルに本質的な良し悪しはないし、たいてい人それぞれの個人的嗜好は異なる。しかし、同じ整形ルールを*一貫して*適用することは、ほぼ全ての場合で可読性を高める。特定のスタイルに馴染んだ読み手は、さらに他のローカルな慣習を理解したり、言語の文法の隅を解読したりする必要がない。

これは文法の重複度が高いScalaにおいては特に重要だ。メソッド呼び出しを例に挙げよう。メソッドは、"`.`"を付けても、ホワイトスペースを付けても呼び出せる。同様に、ゼロまたは一つの引数を取るメソッドでは丸カッコを付けても良いし、付けなくても良い、といった風に。さらに、様々なスタイルのメソッド呼び出しは、様々な文法上の曖昧さを露呈する！ 注意深く選ばれた整形ルールを一貫して適用することで、人間と機械の両方にとって、多くの曖昧さを解決できるのは間違いない。

我々は、[Scala style guide](http://docs.scala-lang.org/style/)を遵守すると同時に、以下に示すルールを追加した。

### ホワイトスペース

インデントはホワイトスペース2個。100カラムを超える行は避けよう。メソッドやクラス、オブジェクトの定義の間は一行空ける。

### 命名

<dl class="rules">
<dt>小さなスコープでは、短い名前を使う</dt>
<dd>ループでは、基本的に<code>i</code>や<code>j</code>や<code>k</code>を使おう。</dd>
<dt>より大きなスコープでは、より長い名前を使う</dt>
<dd>外部APIには、より長くて意味付けのできる説明的な名前を付けるべきだ。<code>Future.all</code>ではなく、<code>Future.collect</code>のように。
</dd>
<dt>一般的な略語を使い、難解な略語を避ける</dt>
<dd>誰でも<code>ok</code>や<code>err</code>や<code>defn</code>が何を指すか知っている。一方で、<code>sfri</code>はそれほど一般的ではない。</dd>
<dt>異なる用途に名前を再利用しない</dt>
<dd><code>val</code>を使おう。</dd>
<dt>予約名を <code>`</code> を使ってオーバーロードするのは避ける</dt>
<dd><code>`type</code>`の代わりに、<code>typ</code>とする。</dd>
<dt>副作用を伴う操作には能動態で名前を付ける</dt>
<dd><code>user.setActive()</code>ではなく、<code>user.activate()</code>とする。</dd>
<dt>値を返すメソッドの名前は説明的に</dt>
<dd><code>src.defined</code>ではなく、<code>src.isDefined</code>とする。</dd>
<dt>getterの接頭に<code>get</code>を付けない</dt>
<dd>上にも書いた通り、これは冗長だ。<code>site.getCount</code>ではなく、<code>site.count</code>とする。</dd>
<dt>パッケージやオブジェクト内で既にカプセル化されている名前を繰り返さない</dt>
<dd><pre><code>object User {
  def getUser(id: Int): Option[User]
}</code></pre>よりも、
<pre><code>object User {
  def get(id: Int): Option[User]
}</code></pre>とする。<code>User.get</code>と比べて<code>User.getUser</code>は冗長だし、何も情報を与えない。
</dd>
</dl>


### インポート

<dl class="rules">
<dt>インポート(import)行はアルファベット順にソートする</dt>
<dd>このようにすると、目で調べやすいし自動化もしやすい。</dd>
<dt>同じパッケージから複数の名前をインポートするときは中カッコを使う</dt>
<dd><code>import com.twitter.concurrent.{Broker, Offer}</code></dd>
<dt>6個より多くの名前をインポートするときはワイルドカードを使う</dt>
<dd>e.g.: <code>import com.twitter.concurrent._</code>
<br />ワイルドカードを濫用しないこと。一部のパッケージは、大量の名前をエクスポートする。</dd>
<dt>コレクションを使う時は、<code>scala.collections.immutable</code> あるいは <code>scala.collections.mutable</code> をインポートして名前を修飾する</dt>
<dd>可変(mutable)コレクションと不変(immutable)コレクションは同じ名前を二重に使っている。読み手のために、名前を修飾してどちらのコレクションを使っているか明確にしよう。 (e.g. "<code>immutable.Map</code>")</dd>
<dt>他のパッケージからの相対指定でインポートしない</dt>
<dd><pre><code>import com.twitter
import concurrent</code></pre>のようには書かず、以下のように曖昧さの無い書き方をしよう。<pre><code>import com.twitter.concurrent</code></pre></dd>
<dt>インポートはファイルの先頭に置く</dt>
<dd>読み手が、全てのインポートを一箇所で参照できるようにしよう。</dd>
</dl>

### 中カッコ

中カッコは、複合式を作るのに使われる（"モジュール言語"では他の用途にも使われる）。複合式の値は、リスト中の最後の式となる。単純な式に中カッコを使うのは避けよう。例えば、

	def square(x: Int) = x*x
	
.LP と書く代わりに、メソッドの本文を構文的に見分けやすい

	def square(x: Int) = {
	  x * x
	}
	
.LP と書きたくなるかもしれない。しかし、最初の記法の方がゴチャゴチャしておらず読みやすい。明確化が目的でないなら<em>仰々しい構文を使うのは避けよう</em>。

### パターンマッチ

関数の定義でパターンマッチを直接使える場合は、いつでもそうしよう。

	list map { item =>
	  item match {
	    case Some(x) => x
	    case None => default
	  }
	}
	
.LP という間接的な書き方は意図が明瞭でない。代わりにmatchを折り畳んで

	list map {
	  case Some(x) => x
	  case None => default
	}

.LP と書くと、リストの要素を写像(map over)しているのが分かりやすい。

### コメント

[ScalaDoc](https://wiki.scala-lang.org/display/SW/Scaladoc)を使ってAPIドキュメントを提供しよう。以下のスタイルで書こう:

	/**
	 * ServiceBuilder builds services 
	 * ...
	 */
	 
.LP でも、標準のScalaDocスタイルは<em>使わない</em>方がいい:

	/** ServiceBuilder builds services
	 * ...
	 */

アスキーアートや視覚的な装飾に頼ってはいけない。また、APIではない不必要なコメントをドキュメント化してはいけない。もし、自分のコードの挙動を説明するためにコメントを追加しているのに気づいたら、まずは、それが何をするコードなのか明白になるよう書き直せないか考え直してみよう。「見るからに、それは動作する (it works, obviously)」よりも「明らかにそれは動作する(obviously it works)」方がいい（ホーアには申し訳ないけど）。

（訳注: [アントニー・ホーア](http://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%B3%E3%83%88%E3%83%8B%E3%83%BC%E3%83%BB%E3%83%9B%E3%83%BC%E3%82%A2)は、自身のチューリング賞受賞講演で*『極めて複雑に設計して「明らかな」欠陥を無くすより、非常に簡素に設計して「明らかに」欠陥が無いようにする方が遥かに難しい』*という趣旨の発言をしている。一方、著者は「コードから実装の意図を一目瞭然に読み取れるようにせよ」という立場であり、つまりホーアとは真逆の主張をしていると言える。）

## 型とジェネリクス

型システム(type system)の主な目的は、プログラミングの誤りを検出することだ。型システムは、制限された形態の静的検査を効果的に提供する。これにより、コードにおいてある種の不変条件(invariant)を記述でき、それをコンパイラで検証できる。型システムがもたらす恩恵はもちろん他にもあるが、エラーチェックこそ、その存在理由（レーゾンデートル）だ。

我々が型システムを使う場合はこの目的を踏まえるべきだが、一方で、読み手にも気を配り続ける必要がある。型を慎重に使ったコードは明瞭さが高まるが、過剰に巧妙に使ったコードは読みにくいだけだ。

Scalaの強力な型システムは、学術的な探求と演習においてよく題材とされる(eg. [Type level programming in
Scala](http://apocalisp.wordpress.com/2010/06/08/type-level-programming-in-scala/))。これらのテクニックは学術的に興味深いトピックだが、プロダクションコードでの応用において有用であることは稀だ。避けるべきだろう。

### 戻り型アノテーション

Scalaでは戻り型アノテーション(return type annotation)を省略できるが、一方で、アノテーションは優れたドキュメンテーションを提供する。戻り型アノテーションは、publicメソッドでは特に重要だ。露出していないメソッドで、かつ戻り型が明白な場合は省略しよう。

これは、ミックスインを使ったオブジェクトをインスタンス化する際に、Scalaコンパイラがシングルトン型を生成する場合は特に重要だ。例えば、`make` 関数が:

	trait Service
	def make() = new Service {
	  def getId = 123
	}

.LP <code>Service</code> という戻り型を<em>持たない</em>場合、コンパイラは細別型(refinement type)である <code>Object with Service{def getId: Int}</code> を生成する。代わりに、明示的なアノテーションを使うと:

	def make(): Service = new Service{}

`make` の公開する型を変更することなく、traitをさらに好きなだけミックスできる。つまり、後方互換性の管理が容易になる。

### 変位

変位(variance)は、ジェネリクスが派生型(subtyping)と結びつく時に現れる。変位は、コンテナ型(*container* type)の派生型と、要素型(*contained* type)の派生型がどう関連するかを定義する。Scalaでは変位アノテーションを宣言できるから、コレクションに代表される共通ライブラリの作者は、多数のアノテーションを扱う必要がある。変位アノテーションは、共用コードの使い勝手を高める上で重要だが、誤用すると危険なものとなりうる。

非変(invariant)は、Scalaの型システムにおいて高度だが必須の特徴だ。派生型の適用を助けるために、大いに（そして正しく）使うべきだ。

*不変コレクションは共変(covariant)であるべきだ*。要素型を受け取るメソッドは、コレクションを適切に"格下げ"すべきだ:

	trait Collection[+T] {
	  def add[U >: T](other: U): Collection[U]
	}

*可変コレクションは非変であるべきだ*。一般的に、可変コレクションにおいて共変は無効だ。この

	trait HashSet[+T] {
	  def add[U >: T](item: U)
	}

.LP と、以下の型階層を見てほしい:

	trait Mammal
	trait Dog extends Mammal
	trait Cat extends Mammal

.LP もし今、犬(Dog)のハッシュセットがあるなら、

	val dogs: HashSet[Dog]

.LP それを哺乳類(Mammal)の集合として扱ったり、猫(Cat)を追加したりできる。

	val mammals: HashSet[Mammal] = dogs
	mammals.add(new Cat{})

.LP これはもはや、犬のHashSetではない！

<!--
  *	when to use abstract type members?
  *	show contravariance trick?
-->

### 型エイリアス

型エイリアス(type alias)は、簡便な名前を提供したり、意味を明瞭にするために使う。しかし、一目瞭然な型はエイリアスしない。

	() => Int

.LP は、簡潔かつ一般的な型を使っているので、

	type IntMaker = () => Int
	IntMaker

.LP よりも明瞭だ。しかし、

	class ConcurrentPool[K, V] {
	  type Queue = ConcurrentLinkedQueue[V]
	  type Map   = ConcurrentHashMap[K, Queue]
	  ...
	}

.LP は、意思疎通が目的で、簡潔さを高めたい場合に有用だ。

エイリアスが使える場合はサブクラス化を使ってはいけない。

	trait SocketFactory extends (SocketAddress) => Socket
	
.LP <code>SocketFactory</code>は、<code>Socket</code>を生成する<em>関数</em>だ。型エイリアス

	type SocketFactory = SocketAddress => Socket

.LP を使う方がいい。これで、<code>SocketFactory</code>型の値となる関数リテラルを定義できるので、関数合成が使える:

	val addrToInet: SocketAddress => Long
	val inetToSocket: Long => Socket

	val factory: SocketFactory = addrToInet andThen inetToSocket

パッケージオブジェクトを使うと、型エイリアスをトップレベル名に結びつけることができる:

	package com.twitter
	package object net {
	  type SocketFactory = (SocketAddress) => Socket
	}

なお、型エイリアスは、その型のエイリアス名を構文的に置換することと同等で、新しい型ではないことに留意しよう。

### 暗黙

暗黙(implicit)は、型システムの強力な機能だが、慎重に使うべきだ。それらの解決ルールは複雑で、シンプルな字句検査においてさえ、実際に何が起きているか把握するのを困難にする。暗黙を間違いなく使ってもいいのは、以下の場面だ:

* Scalaスタイルのコレクションを拡張したり、追加したりするとき
* オブジェクトを適合(adapt)させたり、拡張(extend)したりするとき（"pimp my library"パターン）
* [制約エビデンス](http://www.ne.jp/asahi/hishidama/home/tech/scala/generics.html#h_generalized_type_constraints)を提供することで、*型安全を強化*するために使うとき
* 型エビデンス（型クラス）を提供するため
* `Manifest`のため

暗黙を使う場合は、暗黙を使わずに同じことを達成する方法がないか、常に確認しよう。

似通ったデータ型同士を、自動的に変換するのに暗黙を使うのはやめよう（例えば、リストをストリームに変換する等）。それらの型はそれぞれ異なった動作をするので、読み手は暗黙の型変換が働いていないか注意しなくてはならなくなる。明示的に変換するべきだ。

## コレクション

Scalaが持つコレクションライブラリは、とても総称的(generic)で、機能豊富で、強力で、組み立てやすい。コレクションは高水準であり、多数の操作を提供している。多数のコレクション操作と変換を簡潔かつ読みやすく表現できるが、それらの機能を不注意に適用すると、しばしば正反対の結果を招く。全てのScalaプログラマは、[collections design document](http://scalajp.github.com/scala-collections-doc-ja/)を読むべきだ。このドキュメントは、Scalaのコレクションライブラリに対する優れた洞察と意欲をもたらしてくれる。

常に、君のニーズを最もシンプルに満たすコレクションを使おう。

### 階層

Scalaのコレクションライブラリは巨大だ。`Traversable[T]`を基底とする精密な階層に加えて、ほとんどのコレクションに`immutable`と`mutable`のバリエーションがある。どんなに複雑でも、以下の図は、`immutable`と`mutable`の双方の階層にとって重要な区別を含んでいる。

<img src="coll.png" style="margin-left: 3em;" />
.cmd
pic2graph -format png >coll.png <<EOF 
boxwid=1.0

.ft I
.ps +9

Iterable: [
	Box: box wid 1.5*boxwid
	"\s+2Iterable[T]\s-2" at Box
]

Seq: box "Seq[T]" with .n at Iterable.s + (-1.5, -0.5)
Set: box "Set[T]" with .n at Iterable.s + (0, -0.5)
Map: box "Map[T]" with .n at Iterable.s + (1.5, -0.5)

arrow from Iterable.s to Seq.ne
arrow from Iterable.s to Set.n
arrow from Iterable.s to Map.nw
EOF
.endcmd

.LP <code>Iterable[T]</code>はイテレート(iterate)できるコレクションで、<code>iterator</code>(と<code>foreach</code>)メソッドを提供する。<code>Seq[T]</code>は<em>順序付けされた</em>コレクション。<code>Set[T]</code>は数学的集合（要素が一意な順序の無いコレクション）。そして、<code>Map[T]</code>は順序の無い連想配列だ。

### 使う

*不変(immutable)コレクションを使おう。*不変コレクションは、ほとんどの状況に適用できる。また、プログラムが参照透過であり、故にデフォルトでスレッドセーフであると判断しやすくなる。

*`mutable`名前空間は明示的に使う。*`scala.collections.mutable._`をインポートして`Set`を参照する代わりに、

	import scala.collections.mutable
	val set = mutable.Set()

.LP とすることで、可変な`Set`を使っていることが分かりやすくなる。

*コレクション型のデフォルトコンストラクタを使おう。*例えば、順序付きの（かつ連結リストの動作が必要ない）シーケンスが欲しい場合は、いつでも`Seq()`コンストラクタを使おう:

	val seq = Seq(1, 2, 3)
	val set = Set(1, 2, 3)
	val map = Map(1 -> "one", 2 -> "two", 3 -> "three")

.LP このスタイルでは、コレクションの動作がその実装と切り離されているので、コレクションライブラリは最も適切な実装型を使うことができる。君が必要としているのは<code>Map</code>であって、必ずしも<a href="http://ja.wikipedia.org/wiki/%E8%B5%A4%E9%BB%92%E6%9C%A8">赤黒木</a>じゃない。さらに、これらのデフォルトコンストラクタは、しばしば特殊化された表現を用いる。例えば<code>Map()</code>は、3つのキーを持つマップに対して、3つのフィールドを持つオブジェクト（<a href="http://www.scala-lang.org/api/current/scala/collection/immutable/Map$$Map3.html"><code>Map3</code></a>クラス）を使う。

以上からの結論として、メソッドやコンストラクタでは、*最も総称的なコレクション型を適切に受け取ろう*。要するに、通常は上記の`Iterable`、`Seq`、`Set`あるいは`Map`のうち、どれか一つだ。もしメソッドがシーケンスを必要とする場合は、`List[T]`ではなく`Seq[T]`を使おう。

<!--
something about buffers for construction?
anything about streams?
-->

### スタイル

関数型プログラミングでは、不変コレクションを望みの結果へと変形する方法として、パイプライン化された変換が推奨されている。大抵は、この手法により問題をとても簡潔に解決できるが、同時に読み手を困惑させることもある。変換をパイプライン化すると、しばしば作者の意図を理解するのが困難になり、暗黙的にしか示されていない途中結果を、全て追跡し続けるしかなくなるからだ。例えば、様々なプログラミング言語に対する投票結果である (language, num votes) のシーケンスを集計して、票数の最も多い言語から順番に表示するコードは、以下のように書ける:
	
	val votes = Seq(("scala", 1), ("java", 4), ("scala", 10), ("scala", 1), ("python", 10))
	val orderedVotes = votes
	  .groupBy(_._1)
	  .map { case (which, counts) => 
	    (which, counts.foldLeft(0)(_ + _._2))
	  }.toSeq
	  .sortBy(_._2)
	  .reverse

.LP このコードは、簡潔でかつ正しい。しかし、ほとんどの読み手は、作者の元の意図を把握するのに苦労するだろう。<em>途中結果とパラメータに名前を付ける</em>のは、多くの場合で、作者の意図をハッキリさせるのに役立つ戦略の一つだ:

	val votesByLang = votes groupBy { case (lang, _) => lang }
	val sumByLang = votesByLang map { case (lang, counts) =>
	  val countsOnly = counts map { case (_, count) => count }
	  (lang, countsOnly.sum)
	}
	val orderedVotes = sumByLang.toSeq
	  .sortBy { case (_, count) => count }
	  .reverse

.LP このコードでは、施される変換を中間値の名前に、操作されるデータ構造をパラメータ名にしている。これにより、以前と同じくらい簡潔であるだけでなく、作者の意図がよりいっそう明瞭に表現されている。もし、このスタイルを使うことで名前空間の汚染が心配なら、式を<code>{}</code>でグループ化すると良い:

	val orderedVotes = {
	  val votesByLang = ...
	  ...
	}


### 性能

高水準コレクションライブラリは、（高水準な構築物が一般的にそうであるように）性能の推測が難しい。コンピュータに直接指示するやり方、つまり命令型スタイルから遠ざかるほど、あるコード片が性能に与える影響を厳密に予測するのは困難になる。一方で、正確さを判断することは概して容易だし、読みやすさも向上する。Scalaの場合、Javaランタイムが事態をさらに複雑にしている。Scalaでは、ボクシング操作やアンボクシング操作がユーザから隠されており、性能やメモリ使用量の面で重大なペナルティを被ることがある。

低レベルの詳細に焦点を当てる前に、君のコレクションの使い方が適切かどうか確認しよう。また、データ構造に予期しない漸近的な複雑さがないか確かめよう。Scalaのさまざまなコレクションの複雑さについては、[こちら](http://www.scala-lang.org/docu/files/collections-api/collections_40.html)で述べられている。

性能最適化の第一法則は、君のアプリケーションが*なぜ*遅いのかを理解することだ。最適化を始める前に、君のアプリケーションをプロファイル^[[Yourkit](http://yourkit.com)は良いプロファイラだ。]してデータを取ろう。最初に注目するのは、回数の多いループや巨大なデータ構造だ。最適化への過度な取り組みは、たいてい無駄な努力に終わる。クヌースの「時期尚早な最適化は諸悪の根源("Premature optimisation is the root of all evil.")」という格言を思い出そう。

性能やメモリ使用効率の良さが要求される場面では、多くの場合、低レベルコレクションを使うのが妥当だ。巨大なシーケンスには、リストより配列を使おう（不変の`Vector`コレクションは、配列への参照透過なインタフェースを提供する）。また、性能が重要な場合は、シーケンスを直接生成せずにバッファを使おう。

### Javaコレクション

Javaコレクションとの相互運用のために、`scala.collection.JavaConverters`を使おう。`JavaConverters`は、暗黙変換を行う`asJava`メソッドと`asScala`メソッドを追加する。読み手を助けるために、これらの変換は明示的に行うようにしよう:

	import scala.collection.JavaConverters._
	
	val list: java.util.List[Int] = Seq(1,2,3,4).asJava
	val buffer: scala.collection.mutable.Buffer[Int] = list.asScala

## 並行性

現代のサービスは、サーバへの何万何十万もの同時操作を調整するため、高い並行性(concurrency)を備えている。そして、隠れた複雑性への対処は、堅固なシステムソフトウェアを記述する上で中心的なテーマだ。

*スレッド(thread)*は、並行性を表現する一つの手段だ。スレッドからは、OSによってスケジュールされる、独立したヒープ共有の実行コンテクストを利用できる。しかし、Javaにおいてスレッド生成はコストが高い。そのため、主にスレッドプールを使って、リソースとして管理する必要がある。これは、プログラマにとってさらなる複雑さを生み出す。また、アプリケーションロジックとそれが使用する潜在的なリソースを分離するのが難しくなり、結合度を高めてしまう。

この複雑さは、出力(fan-out)の大きいサービスを作成する際に、とりわけ明らかになる。それぞれの受信リクエストからは、システムのさらに別の階層に対する多数のリクエストが生じる。それらのシステムにおいて、スレッドプールは、各階層でのリクエストの割合によってバランスされるよう管理される必要がある。あるスレッドプールで管理に失敗すると、その影響は他のスレッドプールにも広がってしまう。

また、堅固なシステムは、タイムアウトとキャンセルについても検討する必要がある。どちらに対処するにも、さらなる「制御スレッド」の導入が必要で、そのことが問題をさらに複雑にする。ちなみに、もしスレッドのコストが安いなら、こうした問題は少なくなる。なぜなら、スレッドプールが必要とされず、タイムアウトしたスレッドを放棄することができ、追加のリソース管理も必要ないからだ。

このように、リソース管理はモジュール性を危うくするのだ。

### Future

Futureを使って並行性を管理しよう。Futureは、並行操作とリソース管理を疎結合にする。例えば、[Finagle][Finagle]は、並行操作をわずかなスレッド数で効率的に多重化する。Scalaには、軽量なクロージャリテラルの構文がある。だから、Futureは構文上の負担が小さく、ほとんどのプログラマが身に付けることができる。

Futureは、プログラマが並行計算を宣言的なスタイルで表現できるようにする。Futureは合成可能で、また計算の失敗を原則に基づいて処理できる。こうした性質から、Futureは関数型プログラミング言語にとても適しており、推奨されるスタイルだと確信している。

*生成したFutureを変換しよう。*Futureの変換を使うと、失敗の伝播やキャンセルの通知が行われることを保証できる。また、プログラマは、Javaメモリモデルの影響を検討する必要がなくなる。RPCを順番に10回発行して結果を表示するとき、注意深いプログラマでさえ、以下のように書いてしまうかもしれない:

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

	collect()
	p onSuccess { results =>
	  printf("Got results %s\n", results.mkString(", "))
	}

RPCの失敗が確実に伝播するように、プログラマは、コードに制御フローをいくつも挿入する必要がある。さらに悪いことに、上記のコードは間違っている！ `results`を`volatile`として宣言していないので、各繰り返しにおいて、`results`が一つ前の値を保持していることを保証できない。Javaのメモリモデルは、油断ならない獣だ。しかし幸いにして、宣言的スタイルを使えば、これらの落とし穴を全て避けることができる:

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

シーケンスの操作に`flatMap`を使うと、処理が進むにつれて、リストの先頭に結果を追加できる。これは、関数型プログラミングの一般的なイディオムを、Futureに置き換えたものだ。これは正しく動作するだけでなく、必要な「おまじない」を少なくでき、間違いの元を減らすことができる。そして、読みやすい。

*Futureの結合子(combinator)を使おう。*`Future.select`や`Future.join`、そして`Future.collect`は、複数のFutureを結合して操作する際の一般的なパターンを体系化している。

### コレクション

並行コレクションの話題は、私見と、機微と、教義と、FUDに満ちている。それらは、多くの場合、実践において取るに足らない問題だ。いつでも、目的を果たす上で、最も単純で、最も退屈で、最も標準的なコレクションから始めよう。同期化コレクションでうまくいかないのが*分かる*前に、並行コレクションに手を伸ばしてはいけない。JVMは、同期を低コストで実現する洗練された機構を持っている。その有効性に、君は驚くはずだ。

不変(immutable)コレクションで目的を果たせるなら、それを使おう。不変コレクションは参照透過なので、並行コンテキストでの推論が簡単になる。不変コレクションの変更は、主に（`var`セルや`AtomicReference`が指す）現在の値への参照を更新することで行う。不変コレクションの変更には、注意が必要だ。他のスレッドへ不変コレクションを公開する場合、`AtomicReference`には再試行が必要だし、`var`変数は`volatile`として宣言しなければいけない。

可変(mutable)な並行コレクションは複雑な動作をするだけでなく、Javaメモリモデルの微妙な部分を利用する。だから、可変並行コレクションが更新を公開する方法など、暗黙的な挙動について理解しておこう。また、コレクションの合成には同期化コレクションを使おう。並行コレクションでは、`getOrElseUpdate`のような操作を正しく実装できないし、特に、合成コレクションの作成はエラーの温床だ。

<!--

use the stupid collections first, get fancy only when justified.

serialized? synchronized?

blah blah.

Async*?

-->


## 制御構造

関数型スタイルのプログラムは伝統的な制御構造が少なく済み、また、宣言型スタイルで書かれていると読みやすいことが多い。これは典型的には、ロジックをいくつかの小さなメソッドや関数に分解し、それらを互いに`match`式で貼り合わせることを意味する。また、関数型プログラムは、より式指向となる傾向がある。つまり、条件式のそれぞれの分岐は同じ型の値を計算し、`for (..) yield`で内包(comprehension)を計算する。また、再帰の利用が一般的だ。

### 再帰

*再帰表現を使うと、問題をしばしば簡潔に記述できる。*そしてコンパイラは、末尾呼び出しの最適化が適用できるコードを正規のループに置き換える（末尾最適化が適用されるかは`@tailrec`アノテーションで確認できる）。

ヒープの<span class="algo">fix-down</span>を、極めて標準的な命令型で実装したバージョンを検討しよう:

	def fixDown(heap: Array[T], m: Int, n: Int): Unit = {
	  var k: Int = m
	  while (n >= 2*k) {
	    var j = 2*k
	    if (j < n && heap(j) < heap(j + 1))
	      j += 1
	    if (heap(k) >= heap(j))
	      return
	    else {
	      swap(heap, k, j)
	      k = j
	    }
	  }
	}

このコードでは、whileループに入るたび、一つ前の反復で変更された状態を参照する。各変数の値は、どの分岐を取るかに依存する。また、正しい位置が見つかると、関数はループの中盤で`return`する（鋭い読者は、ダイクストラの["Go To Statement Considered Harmful"](http://www.u.arizona.edu/~rubinson/copyright_violations/Go_To_Considered_Harmful.html)に同様の議論があることに気づくと思う）。

（末尾）再帰による実装を検討してみよう^[[Finagle's heap
balancer](https://github.com/twitter/finagle/blob/master/finagle-core/src/main/scala/com/twitter/finagle/loadbalancer/Heap.scala#L41)より]:

	@tailrec
	final def fixDown(heap: Array[T], i: Int, j: Int) {
	  if (j < i*2) return
	
	  val m = if (j == i*2 || heap(2*i) < heap(2*i+1)) 2*i else 2*i + 1
	  if (heap(m) < heap(i)) {
	    swap(heap, i, m)
	    fixDown(heap, m, j)
	  }
	}

.LP ここでは、すべての反復ははっきりと<em>白紙の状態で</em>開始される。また、参照セルが存在しないため、不変式(invariant)を数多く見出せる。このコードはより推論しやすいだけでなく、より読みやすい。それだけでなく、性能面のペナルティもない。コンパイラは、メソッドが末尾再帰なら、これを標準的な命令型のループへと変換するからだ。

（訳注: [エドガー・ダイクストラ](http://ja.wikipedia.org/wiki/%E3%82%A8%E3%83%89%E3%82%AC%E3%83%BC%E3%83%BB%E3%83%80%E3%82%A4%E3%82%AF%E3%82%B9%E3%83%88%E3%83%A9)は、構造化プログラミングの提唱者。彼が執筆したエッセイ"Go To Statement Considered Harmful"は、「GOTO有害論」の端緒として有名。）

<!--
elaborate..
-->


### Return

前節では再帰を使うメリットを紹介したけど、だからといって命令型の構造は無価値だというわけじゃない。多くの場合、計算を早期に終了する方が、終点の可能性がある全ての位置に条件分岐を持つよりも適切だ。実際に、上記の`fixDown`は、ヒープの終端に達すると`return`によって早期に終了する。

`return`を使うと、分岐を減らして不変式(invariant)を定めることができる。これにより、入れ子が減ってコードを追いやすくなるだけでなく、後続のコードの正当性を論証しやすくなる（配列の範囲外をアクセスしないことを確認する場合とか）。これは、"ガード"節で特に有用だ:

	def compare(a: AnyRef, b: AnyRef): Int = {
	  if (a eq b)
	    return 0
	
	  val d = System.identityHashCode(a) compare System.identityHashCode(b)
	  if (d != 0)
	    return d
	    
	  // slow path..
	}

`return`を使って、コードを明快にして読みやすさを高めよう。ただし、命令型言語でのような使い方をしてはいけない。つまり、下記のように計算結果を返すために`return`を使うのは避けよう。

	def suffix(i: Int) = {
	  if      (i == 1) return "st"
	  else if (i == 2) return "nd"
	  else if (i == 3) return "rd"
	  else             return "th"
	}

.LP 代わりに下記のように書こう:

	def suffix(i: Int) =
	  if      (i == 1) "st"
	  else if (i == 2) "nd"
	  else if (i == 3) "rd"
	  else             "th"

.LP しかし、より優れているのは<code>match</code>式を使うことだ:

	def suffix(i: Int) = i match {
	  case 1 => "st"
	  case 2 => "nd"
	  case 3 => "rd"
	  case _ => "th"
	}

なお、クロージャの内部で`return`を使うと、目に見えないコストが発生する場合があるので注意しよう。

	seq foreach { elem =>
	  if (elem.isLast)
	    return
	  
	  // process...
	}
	
.LP このコードは、バイトコードでは例外の`throw`と`catch`として実装されるので、実行頻度の高いコードで使うと性能に影響を与える。

### `for`ループと内包

`for`を使うと、ループと集約を簡潔かつ自然に表現できる。`for`は、多数のシーケンスを平坦化(flatten)する場合に特に有用だ。`for`の構文は、内部的にはクロージャを割り当ててディスパッチしていることを覆い隠している。このため、予期しないコストが発生したり、予想外の挙動を示したりする。例えば、

	for (item <- container) {
	  if (item != 2) return
	}

.LP このコードは、`container`が計算を遅延させた場合にランタイムエラーが発生し、その結果として<code>return</code>が非局所的(nonlocal)に評価されてしまうことがある！

これらの理由から、コードを明瞭にするためである場合を除いて、`for`を使う代わりに、`foreach`や`flatMap`や`map`や`filter`を直接呼び出す方が良いことが多い。

（訳注1: Scalaのfor式は`foreach`、`flatMap`、`map`、`withFilter`を呼び出す糖衣構文で、ループ内の式は、コンパイル時にそれらのメソッドに渡される匿名関数に変換される。例えば、上記の例のfor式は、実際には

	container foreach { item =>
	  if (item != 2) return
	}

というコードとして実行される。原文では、最初からこのように記述することを推奨している。）

（訳注2: ネストした匿名関数での`return`式は、ランタイムエラーである`NonLocalReturnException`の`throw`と`catch`に変換される。この場合、`container`が遅延評価されると`return`式の挙動が意図しないものになる場合がある。詳細に興味がある場合は、[こちらの議論](https://github.com/okapies/effectivescala/commit/8b448ef819e6d87d21fa78310b84fc72593b0226#commitcomment-996948)も参照してほしい。）

### `require`と`assert`

`require`と`assert`は、どちらも実行可能なドキュメントとして機能する。これらは、要求される不変条件(invariant)を型システムが表現できない状況で有用だ。`assert`は、コードが仮定する（内部あるいは外部の）*不変条件*を表現するために使われる。例えば、

	val stream = getClass.getResourceAsStream("someclassdata")
	assert(stream != null)

一方で、`require`はAPIの契約を表現するために使われる:

	def fib(n: Int) = {
	  require(n > 0)
	  ...
	}

## 関数型プログラミング

関数型プログラミングと一緒に用いる時に *値指向型* プログラミングは多くの恩恵を受ける。このスタイルはステートフルな変更よりも値の変換を強調する。得られるコードは参照透過(referentially transparent)であり、より強力な不変式(invariant)を提供し、さらに容易に推論することが可能になる。ケースクラス、パターンマッチ、構造化代入(destructuring-bind)、型推論、軽量クロージャ、メソッド生成構文がこのツールになる。

### 代数的データ型としてのケースクラス

ケースクラス(case class)は代数的データ型(ADT)をエンコードする。パターンマッチと共に利用することで、ケースクラスは巨大なデータ構造をモデリングするのに役に立ち、強力な不変式を簡潔なコードとして提供する。パターンマッチの解析器は、さらに強力な静的保証を提供する包括的解析(exhaustivity analysis)を実装している。
ケースクラスと共に代数的データ型をエンコードする時、以下のパターンを使おう：

	sealed trait Tree[T]
	case class Node[T](left: Tree[T], right: Tree[T]) extends Tree[T]
	case class Leaf[T](value: T) extends Tree[T]

<code>Tree[T]</code>の型は<code>Node</code>と<code>Leaf</code>の2つのコンストラクタを持つ。<code>sealed</code>として型を宣言する事で、ソースファイルの外からコンストラクタを追加することを制限できるため、コンパイラに包括的解析を行わせることができる。

パターンマッチと一緒に利用することで、そのようなモデリングを簡潔かつ"明らかに正しい"コードにすることができる。

	def findMin[T <: Ordered[T]](tree: Tree[T]) = tree match {
	  case Node(left, right) => Seq(findMin(left), findMin(right)).min
	  case Leaf(value) => value
	}

ツリーのような再帰構造は代数的データ型の古典的なアプリケーションを構成する一方で、それらの有用な領域はかなり大きい。
代数的データ型でモデリングされた結合の分解は状態遷移(state machines)で頻繁に発生する。

### オプション

`Option`型は、空であること(`None`)、または満たされていること(`Some(value)`)を表すコンテナである。`null`に対する安全な代替手段を提供し、可能な限り如何なる時も利用されるべきである。`Option`型は、たかだかひとつの要素を持つコレクションであり、コレクションの操作で装飾される。利用しよう！

`Option`型は、無(`None`)か、有(`Some(Value)`)のどちらかを格納するコンテナである。nullの代わりに安全に使用でき、いつでも可能な限り使用されるべきである。
`Option`型は(たかだかひとつの一つの要素しかない)コレクションであり、集合の操作で利用できる。使うしかない!


以下のように書こう。

	var username: Option[String] = None
	...
	username = Some("foobar")

.LP 以下のようには書かない。

	var username: String = null
	...
	username = "foobar"

.LP 前者の方が安全な理由：<code>Option</code>型は<code>username</code>が空であることをチェックされなければならないことを静的に強要しているため。

`Option`の値の条件節の実行は`foreach`を使うべきである。以下の代わりに、

	if (opt.isDefined)
	  operate(opt.get)

.LP 以下のように書く

	opt foreach { value =>
	  operate(value)}

奇妙なスタイルに思えるかもしれないが、よりよい安全性を提供(例外を引き起こしうる`get`を呼んでいない)し、簡潔である。両方の選択肢が利用されうるなら、パターンマッチを使おう。

	opt match {
	  case Some(value) => operate(value)
	  case None => defaultAction()
	}

.LP しかし、もし値がない場合はデフォルト値で良いのであれば、<code>getOrElse</code>を使おう。

	operate(opt getOrElse defaultValue)

`Option`を多用しすぎてはいけない。もし、何か目的にあったデフォルト値、[*Null Object*](http://en.wikipedia.org/wiki/Null_Object_pattern)、があるなら、代わりにそれを使おう。

`Option`は、また、nullになり得る値を覆う扱いやすいコンストラクターと共に使おう。

	Option(getClass.getResourceAsStream("foo"))

.LP は、<code>Option[InputStream]</code> であり、<code>getResourceAsStream</code> が <code>null</code> を返す場合に、<code>None</code>  という値を返す。

### パターンマッチ

パターンマッチ (`x match { ...`) は、Scalaで書かれたコード内に広く使われている。パターンマッチは条件の実行および分解(destructuring)、ひとつの構成物へのキャストを合成する。うまく使うことで明快さと安全さの両方をより高めてくれる。

型ごとの処理を実装するためにパターンマッチを使う。

	obj match {
	  case str: String => ...
	  case addr: SocketAddress => ...

 
パターンマッチは、分解とあわせて利用された時(たとえば、ケースクラスをマッチングするとき)に最大限に役立つ
次の例のように書くべきではなく、

	animal match {
	  case dog: Dog => "dog (%s)".format(dog.breed)
	  case _ => animal.species
	  }

.LP 以下のように書く

	animal match {
	  case Dog(breed) => "dog (%s)".format(breed)
	  case other => other.species
	}


ただ、2つのコンストラクタ(`apply`) を利用する場合のみ、[カスタム抽出子] (http://www.scala-lang.org/node/112) を書く。
さもなければ不自然になる可能性がある。


デフォルト値がもっと意味を持つものであるとき、条件実行にパターンマッチを使わないようにする。
コレクションライブラリは通常`Option`を返すメソッドを提供する。次の例は避けよ。

	val x = list match {
	  case head :: _ => head
	  case Nil => default
	}

.LP なぜなら

	val x = list.headOption getOrElse default

.LP の方がより短く、目的が伝わりやすいからだ。

### 部分関数

Scala は 部分関数(`PartialFunction`) を定義するための構文上の簡略的記法を提供する。

	val pf: PartialFunction[Int, String] = {
	  case i if i%2 == 0 => "even"
	}

.LP また、これらは <code>orElse</code> と組み合わせられる。

	val tf: (Int => String) = pf orElse { case _ => "odd"}

	tf(1) == "odd"
	tf(2) == "even"

部分関数は多くの場面で起こり得るものであり，`PartialFunction` で効率的に符号化される。
メソッドの引数として利用する例：

	trait Publisher[T] {
	  def subscribe(f: PartialFunction[T, Unit])
	}

	val publisher: Publisher[Int] = ..
	publisher.subscribe {
	  case i if isPrime(i) => println("found prime", i)
	  case i if i%2 == 0 => count += 2
	  /* ignore the rest */
	}

.LP また状況によっては <code>Option</code> を返すような呼び出しがあるかもしれないが、

	// Attempt to classify the the throwable for logging.
	type Classifier = Throwable => Option[java.util.logging.Level]

.LP これも、<code>PartialFunction</code>を使って表現する方がよいだろう。

	type Classifier = PartialFunction[Throwable, java.util.Logging.Level]

.LP それはより優れた構成可能性(composability)につながるからだ。

	val classifier1: Classifier
	val classifier2: Classifier

	val classifier = classifier1 orElse classifier2 orElse { _ => java.util.Logging.Level.FINEST }


### Destructuring bindings

Destructuring bindによる値代入は、パターンマッチに関連している。
それらは同じメカニズムを利用しているが、(例外の可能性を許容しないために)正確にひとつの選択肢があるときだけ適用できる。
Destructuring bindは特にタプルやケースクラスで有用である。

	val tuple = ('a', 1)
	val (char, digit) = tuple

	val tweet = Tweet("just tweeting", Time.now)
	val Tweet(text, timestamp) = tweet

（訳注: Destructuring bindは、「構造化代入」や「分配束縛」等の訳がある。詳細については、[こちらの議論](https://github.com/okapies/effectivescala/issues/4)を参照してほしい。）

### 遅延評価

Scala のフィールドは、`val` が `lazy` プレフィックスと共に使われた時は *必要になったときに* 計算されるようになる。
なぜなら、(フィールドを `private[this]` にしない限りは)フィールドとメソッドは Scala では等価だからである。

	lazy val field = computation()

.LP は、(概して) 簡略的記法で、

	var _theField = None
	def field = if (_theField.isDefined) _theField.get else {
	  _theField = Some(computation())
	  _theField.get
	}

.LP すなわち、結果を演算し記憶する。この目的のために遅延フィールドを使うようにし、しかし、遅延さが意味を持って(by semantics)要求されるときには遅延評価を使うことを避ける。
このような場合には、コストモデルを明確にし、副作用をより正確に制御するために明示的であることがよりよい。

遅延フィールドはスレッドセーフである。

### 名前呼び出し

メソッドの引数は名前によって特定されるかもしれない、その意味するところは
パラメータは値に紐付くのではなくて、繰り返し実行されうる *演算* に対して紐付くということである。
この機能は気をつけて適用されなければならない。値渡しの文脈を期待している呼び出し側は驚くであろう。
この機能は構文的に自然な DSL を構築するためにある。-- 新しい制御構造は特に、かなりネイティブな言語機能に見えるように作ることができる

名前呼び出しは、そのような制御構造のためだけに使うことだ。そこでは、渡されてくるものは、
思いも寄らない演算結果より"ブロック"であるということが、呼び出し側に明らかである。
名前呼び出しは、最後の引数リストの最後の位置にある引数にだけ使うことだ。
名前呼び出しを使うときは、呼び出し側にその引数が名前呼び出しであることが明確に伝わるようにメソッドには名称をつけることを確実におこなう。

値を複数回演算させたいとき、また特にその演算が副作用を持つとき、陽関数(explicit functions)を使う。


	class SSLConnector(mkEngine: () => SSLEngine)

.LP 目的は明らかに残しつつ、呼び出し元が驚くことがなくなる。

### `flatMap`

`map` と `flatten` の合成である `flatMap` は、鋭敏な力と素晴らしい実用性を持ち、特別な注目を浴びるに値する。
その同類である `map` のように、`Future` や `Option` といった非伝統的なコレクションにおいて、頻繁に利用できる。
その振る舞いは、`Container[A]`といったシグネチャによって明らかになる。
 
	flatMap[B](f: A => Container[B]): Container[B]

.LP <code>flatMap</code> は、<em>新しい</em> コレクションを生成するコレクションの各要素に対して関数 <code>f</code> を呼び出し、それら(のすべて)は、
フラットな結果になる。例えば、次のコードは、同じ文字が繰り返されない2文字からなる文字列の順列をすべて取得する。
 
	val chars = 'a' to 'z'
	val perms = chars flatMap { a =>
	  chars flatMap { b =>
	    if (a != b) Seq("%c%c".format(a, b))
	    else Seq()
	  }
	}

.LP これは、より簡潔な for による包含に等価である。(それは、&mdash; 荒くまとめるなら &mdash; 上記のためのシンタックスシュガーである)
 
	val perms = for {
	  a <- chars
	  b <- chars
	  if a != b
	} yield "%c%c".format(a, b)

`flatMap` は、(Optionの連鎖(chain of options)を畳み込んでひとつにするときなど) `Option` を扱うときに頻繁に役に立つ。
 
	val host: Option[String] = ..
	val port: Option[Int] = ..
	
	val addr: Option[InetSocketAddress] =
	  host flatMap { h =>
	    port map { p =>
	      new InetSocketAddress(h, p)
	    }
	  }

.LP これも、<code>for</code> を使えばもっと簡潔に記述できる。
 
	val addr: Option[InetSocketAddress] = for {
	  h <- host
	  p <- port
	} yield new InetSocketAddress(h, p)

`Future` における `flatMap` の利用については、<a href="#Twitter's%20standard%20libraries-Futures">futures section</a> で議論されている。

## オブジェクト指向プログラミング

Scala の広大な広がりの大部分はオブジェクト機構にある。Scala は、 *すべての値* がオブジェクトであるという意味で、 *純粋な* 言語である。プリミティブな型と混合型の間に違いはない。 Scala はミックスインの機能もあり、静的型チェックの利益をすべて享受しつつ、もっと直行して別々なモジュールをコンパイル時に柔軟に一緒に組立てられる。

ミックスイン機構の背景ある動機は、伝統的な依存性注入を不要にすることである。その"コンポーネントスタイル"プログラミングの極致は、 [Cake
パターン](http://jonasboner.com/2008/10/06/real-world-scala-dependency-injection-di/) である。

（訳注: 上記のCakeパターンに関するエントリは、@eed3si9n氏が[日本語訳](http://eed3si9n.com/ja/real-world-scala-dependency-injection-di)を提供している。）

### 依存性注入

しかし、我々の場合、Scala それ自身が、"クラシックな"（コンストラクタによる）依存性注入(dependency injection)の多くの構文上のオーバーヘッドを排除してくれるため、むしろ、使うようにしている。それはより明快であり、依存性は(コンストラクタの)型でまだエンコードされ、クラスの組立は構文上、そよ風並に些細な作業に過ぎない。それは退屈でシンプルだが動作する。*プログラムのモジュール化のために依存性注入を使うことだ*。特に、*継承より合成を選択することだ* 。これにより、よりモジュール化が進みテスト可能なプログラムになる。継承が必要な状況に遭遇した際には自分自身に問うのだ：もし、言語が継承をサポートしていなかったら、どのように構造化するだろう、と。この答えは強いることができるかもしれない。

依存性注入は典型的にはトレイトを利用する。

     trait TweetStream {
       def subscribe(f: Tweet => Unit)
     }
     class HosebirdStream extends TweetStream ...
     class FileStream extends TweetStream ..

     class TweetCounter(stream: TweetStream) {
       stream.subscribe { tweet => count += 1 }
     }

*ファクトリー* (オブジェクトを生成するオブジェクト)を注入することは一般的である。以下のような場合には、特化したファクトリー型よりはシンプルな関数の利用を好むようにする。

     class FilteredTweetCounter(mkStream: Filter => TweetStream) {
       mkStream(PublicTweets).subscribe { tweet => publicCount += 1 }
       mkStream(DMs).subscribe { tweet => dmCount += 1 }
     }

### トレイト

依存性注入は、一般的な *インターフェイス* の利用や、トレイト(trait)での共通コードの実装を妨げるものでは全くない。むしろ全く反対であり、トレイトの利用は正確には次の理由で強く推奨されている：複数のインターフェイス(トレイト)は、具象クラスで実装されるかもしれないし、共通コードはすべてのそれらのクラス群に横断的に再利用されるかもしれない。

トレイトは短くて直交するように保つことだ。分割可能な機能をひとつのトレイトの塊にしてしまってはいけない。最も小さな関連するアイデアだけを一緒にすることを考えるようにする。たとえば、IOをする何かを想像してみるといい。

     trait IOer {
       def write(bytes: Array[Byte])
       def read(n: Int): Array[Byte]
     }

.LP これを２つの振る舞いに分離する。

     trait Reader {
       def read(n: Int): Array[Byte]
     }
     trait Writer {
       def write(bytes: Array[Byte])
     }

.LP そして、もともと<code>IOer</code> だったこれらを、 <code>new Reader with Writer</code>&hellip; のようにミックスする。インターフェイスの最小化は、よりよい直交性とよりよりモジュール化につながる。

### 可視性

Scala は非常に表現豊かな可視性を制御する修飾子を持つ。修飾子は、何を *公開API* として構成するかを定義するのに重要である。公開APIは限定されるべきであり、それにより利用者は不注意に実装の詳細に依存することはなくなり、また、作者のAPIを変更する力を制限する。このことは、良いモジュール性にとって決定的に重要である。ルールとして、公開APIを拡張することは、彼らと契約するよりも全然簡単である。貧相なアノテーションは、君のコードの後方バイナリ互換性を汚すこともできるようにもなる。


#### `private[this]`

`private` にしたクラスメンバーは、

     private val x: Int = ...

.LP そのクラスの(サブクラスは含まない)すべての<em>インスタンス</em>から見える。殆どの場合、<code>private[this]</code>としたいだろう。

     private[this] val: Int = ..

.LP これで特定のインスタンスのみに可視性は制限された。Scala コンパイラーは、<code>private[this]</code> を(静的に定義されたクラスにアクセスが限られるから)シンプルなフィールドアクセッサに変換することもでき、それは時々、性能を最適化することに寄与する。

#### シングルトンクラス型

Scala では、シングルトンクラス型を生成することは一般的である。例えば、

     def foo() = new Foo with Bar with Baz {
       ...
     }

.LP このような状況では、戻り型を宣言することで可視性は限定される。

     def foo(): Foo with Bar = new Foo with Bar with Baz {
       ...
     }

.LP <code>foo()</code> の呼び出し側は、戻り値のインスタンスの限定されたビュー(<code>Foo with Bar</code>) を参照する。

### 構造的部分型

構造的部分型(structural type)は通常は使わない。構造的部分型は、便利で強力な機能であるが、残念なことに JVM 上では効率的な実装手段はない。しかし、ある運命のいたずらともいうべき実装によって、リフレクションをするためのとても良い速記法を提供する。

     val obj: AnyRef
     obj.asInstanceOf[{def close()}].close()

（訳注: "structural typing"を直訳すると「構造的な型付け」だが、Scalaの文脈では「構造的部分型(structural subtyping)」と同じ意味だと考えて良い。この用語の背景については、[@kmizu氏による解説](https://github.com/okapies/effectivescala/pull/1#r455268)を参照して欲しい。）

## ガベージコレクション

我々は、運用時にガベージコレクションのチューニングに多くの時間を費やす。
ガベージコレクションの考慮事項はかなりJavaのそれに似ているが、典型的な Scala コードの場合は 典型的な Java コードより多くの(生存時間の短い)ガベージを生成する。これは関数スタイルの副作用なのである。HotSpot の世代別ガベージコレクションは、ほとんどの環境では生存時間の短いガベージを効果的に解放するので、概してこれは問題にならない。

GCの性能問題に取り組む前に、Attila が発表した我々のGCチューニングに関する経験のいくつかに関する[プレゼンテーション](http://www.infoq.com/presentations/JVM-Performance-Tuning-twitter)を見て欲しい。


Scala 固有で、GC問題を軽減する唯一のツールは、ガベージの生成をより少なくすることである。しかし、データなしで行動してはならない！もし、明らかに悪化させる何かをしているわけではないのであれば、我々の提供する [heapster](https://github.com/mariusaeriksen/heapster) や
[gcprof](https://github.com/twitter/jvmgcprof) を含む、Java の様々なプロファイルツールを使うことだ。

## Java 互換性

我々は、Javaで利用されるようなコードを Scala で書くとき、Javaでの使い方を慣用的に残して良いものか確かめるようにしている。大体は余計な努力は必要ない。クラス群と実装を含まないトレイトはJava に正確に等価に対応される。しかし、時々、別に Java API を提供する必要がある。あなたのライブラリのJava API の感じをつかむ良い方法は単体テストをJavaで書くことである(ただコンパイルが通れば良い)。この点については Scala コンパイラーは不安定であるのだが、このテストによって、あなたのライブラリの Java 視点は安定さを維持できる。

実装を含むトレイトは直接 Java から利用できない。代わりに抽象クラスをトレイトと共に拡張する必要がある。

     // 直接 Java からは利用できない
     trait Animal {
       def eat(other: Animal)
       def eatMany(animals: Seq[Animal) = animals foreach(eat(_))
     }

     // しかし、これなら利用できる
     abstract class JavaAnimal extends Animal

## Twitterの標準ライブラリ

Twitterにおいて、最も重要な標準ライブラリは[Util](http://github.com/twitter/util)と[Finagle](https://github.com/twitter/finagle)だ。Utilは、ScalaやJavaの標準ライブラリの拡張という位置付けで、それらに欠けている機能やより適切な実装を提供する。Finagleは、TwitterのRPCシステムで、分散システムの構成要素の中核だ。

### Future

Futureについては、<a href="#並行性">並行性</a>の章でも少し<a href="#並行性-Future">議論した</a>。Futureは、非同期処理の連係において重要な機構で、TwitterのコードベースやFinagleのコアで広く使われている。Futureは、並行イベントの合成(composition)を可能にすると共に、高度な並行操作についての判断を単純化する。また、Futureを使うと、並行操作をJVM上で極めて効率的に実装できる。

ネットワーク入出力やディスク入出力等の操作は、基本的にスレッドの実行を一時停止する可能性がある。TwitterのFutureは*非同期的*なので、ブロックする操作(blocking operation)は、操作結果に対するFutureを提供するシステム自身によって処理されなければいけない。Finagleは、ネットワーク入出力のためのそうしたシステムを提供する。

Futureは、単純明白だ。Futureは、まだ完了していない計算の結果に対する*約束(promise)*を保持する、単純なコンテナ（プレースホルダ）だ。当然、計算は失敗することがあるので、このこともコード化する必要がある。Futureは三つの状態、すなわち*保留(pending)*、*失敗(failed)*、*完了(completed)*のうち、きっかり一つの状態を取ることができる。

<div class="explainer">
<h3>余談: <em>合成(composition)</em></h3>
<p>もう一度確認すると、合成とは、単純なコンポーネントを結合してより複雑なコンポーネントにすることだ。合成の標準的な例は、関数合成だ。関数<em>f</em>と<em>g</em>が与えられたとき、合成関数<em>(g&#8728;f)(x) = g(f(x))</em>は、まず<em>x</em>を<em>f</em>に適用し、その結果を<em>g</em>に適用した結果だ。この合成関数をScalaで書くと:</p>

<pre><code>val f = (i: Int) => i.toString
val g = (s: String) => s+s+s
val h = g compose f  // : Int => String
	
scala> h(123)
res0: java.lang.String = 123123123</code></pre>

.LP この関数<em>h</em>は合成関数で、<em>f</em>と<em>g</em>の双方を所定の方法で結合した<em>新しい</em>関数だ。
</div>

Futureは、ゼロ個あるいは一個の要素を持つコンテナであり、コレクションの一種だ。Futureは、`map`や`filter`や`foreach`といった、標準コレクションのメソッドを持つ。Futureの値は遅延されるので、必然的にこれらのコレクションメソッドを適用した結果もまた遅延される。

	val result: Future[Int]
	val resultStr: Future[String] = result map { i => i.toString }

.LP 関数<code>{ i => i.toString }</code>は、Int値が利用可能になるまで呼び出されない。また、変換されたコレクションである<code>resultStr</code>も、その時まで保留状態(pending state)になる。

リストは平坦化(flatten)できる;

	val listOfList: List[List[Int]] = ..
	val list: List[Int] = listOfList.flatten

.LP また、平坦化はFutureにおいても意味をなす:

	val futureOfFuture: Future[Future[Int]] = ..
	val future: Future[Int] = futureOfFuture.flatten

.LP Futureの<code>flatten</code>の実装は、直ちにFutureを返す。Futureは遅延するので、<code>flatten</code>が返すFutureは、外側のFuture(<code><b>Future[</b>Future[Int]<b>]</b></code>)の完了と、その後に内側のFuture(<code>Future[<b>Future[Int]</b>]</code>)の完了を待つ結果だ。また、外側のFutureが失敗したら、平坦化されたFutureも失敗する必要がある。

Futureは、Listと同様に`flatMap`を定義している。`Future[A]`は、そのシグネチャを以下のように定義する。

	flatMap[B](f: A => Future[B]): Future[B]
	
.LP `flatMap`は、<code>map</code>と<code>flatten</code>の組み合わせのようなもので、以下のように実装できる:

	def flatMap[B](f: A => Future[B]): Future[B] = {
	  val mapped: Future[Future[B]] = this map f
	  val flattened: Future[B] = mapped.flatten
	  flattened
	}

これは、強力な組み合わせだ！ `flatMap`によって、二番目のFutureを最初のFutureの結果に基づいて計算する、順番に並べられた二つのFutureの結果である新しいFutureを定義できる。ユーザ(ID)を認証するために、二つのRPCを実行する必要がある場合を想像してほしい。この場合、合成された操作を以下の方法で定義できる:

	def getUser(id: Int): Future[User]
	def authenticate(user: User): Future[Boolean]
	
	def isIdAuthed(id: Int): Future[Boolean] = 
	  getUser(id) flatMap { user => authenticate(user) }

.LP この種の結合のもう一つの恩恵は、エラー処理が組み込まれていることだ。<code>getUser(..)</code>か<code>authenticate(..)</code>が追加でエラー処理をしない限り、<code>isAuthed(..)</code>が返すFutureは失敗するだろう。

#### スタイル

Futureのコールバックメソッドである`respond`や`onSuccess'、`onFailure`、`ensure`は、その親に*連鎖した(chained)*新たなFutureを返す。このFutureは、その親が完了して初めて完了することが保証されている。このパターンを実現するには、例えば以下のようにする。

	acquireResource()
	future onSuccess { value =>
	  computeSomething(value)
	} ensure {
	  freeResource()
	}

.LP このとき<code>freeResource()</code>は、<code>computeSomething</code>の後にのみ実行されることが保証される。これにより、ネイティブな<code>try .. finally</code>パターンのエミュレートが可能になる。

`foreach`の代わりに`onSuccess`を使おう。`onSuccess`の方が`onFailure`と対称を成して目的をより良く表せるし、連鎖も可能になる。

できるだけ自分で`Promise`を作らないようにしよう。ほぼ全てのタスクは、定義済みの結合子を使って実現できる。結合子は、エラーやキャンセルが伝播することを保証すると共に、一般的に*データフロー方式*でのプログラミングを促進する。データフロー方式を使うと、大抵、<a href="#並行性-Future">同期化や`volatile`宣言が不要になる</a>。

末尾再帰方式で書かれたコードはスペースリークに影響されないので、データフロー方式を使ってループを効率的に実装できる:

	case class Node(parent: Option[Node], ...)
	def getNode(id: Int): Future[Node] = ...

	def getHierarchy(id: Int, nodes: List[Node] = Nil): Future[Node] =
	  getNode(id) flatMap {
	    case n@Node(Some(parent), ..) => getHierarchy(parent, n :: nodes)
	    case n => Future.value((n :: nodes).reverse)
	  }

`Future`は、数多くの有用なメソッドを定義している。`Future.value()`や`Future.exception()`を使うと、事前に結果が満たされたFutureを作れる。`Future.collect()`や`Future.join()`、`Future.select()`は、複数のFutureを一つにまとめる結合子を提供する（ie. scatter-gather操作のgather部分）。

（訳注: スペースリーク(space leak)とは、意図せずに空間計算量が非常に大きいコードを書いてしまうこと。関数型プログラミングでは、遅延評価式を未評価のまま蓄積するようなコードを書くと起きやすい。）

#### キャンセル

Futureは、弱いキャンセルを実装している。`Future#cancel`の呼び出しは、計算を直ちに終了させるのではなく、レベルトリガ方式の*シグナル*を伝播する。最終的にFutureを満たすのがいずれの処理であっても、シグナルに問い合わせる(query)ことができる。キャンセルは、値から反対方向へ伝播する。つまり、消費者(consumer)がセットしたキャンセルのシグナルは、対応する生産者(producer)へと伝播する。生産者は`Promise`にある`onCancellation`を使って、シグナルに応じて作動するリスナーを指定する。

つまり、キャンセルの動作は生産者に依存し、デフォルトの実装は存在しない。*キャンセルはヒントに過ぎない。*

#### Local

Utilライブラリの[`Local`](https://github.com/twitter/util/blob/master/util-core/src/main/scala/com/twitter/util/Local.scala#L40)は、ローカルから特定のFutureのディスパッチツリーへの参照セルを提供する。`Local`の値をセットすると、同じスレッド内のFutureによって遅延されるあらゆる計算が、この値を利用できるようになる。これらはスレッドローカルに似ているけど、そのスコープはJavaのスレッドでなく、"Futureスレッド"のツリーだ。

	trait User {
	  def name: String
	  def incrCost(points: Int)
	}
	val user = new Local[User]

	...

	user() = currentUser
	rpc() ensure {
	  user().incrCost(10)
	}

.LP ここで、<code>ensure</code>ブロックの中の<code>user()</code>は、コールバックが追加された時点での<code>user</code>(Local)の値を参照する。

スレッドローカルと同様に`Local`は非常に便利なこともあるが、ほとんどの場合は避けるべきだ。データを明示的に渡して回るのは、たとえそうした方が負担が少なくても、問題を十分に解決できないことを確認しよう。

Localは、RPCのトレースを介したスレッド管理や、モニターの伝播、Futureコールバックのための"スタックトレース"の作成など、*とても*一般的な関心事(concern)を実現する際に、その他の解決策ではユーザに過度な負担がある場合、コアとなるライブラリにおいて効果的に使われる。Localは、その他のほとんどの場面では不適切だ。

<!--
  ### Offer/Broker

-->

## 謝辞

本レッスンは、Twitter社のScalaコミュニティによるものだ。私は、誠実な記録者でありたい。

Blake MathenyとNick Kallen、そしてSteve Guryには、とても有益な助言と多くの優れた提案を与えてもらった。

### 日本語版への謝辞

本ドキュメントの日本語訳は、[@okapies](http://github.com/okapies)と[@scova0731](https://github.com/scova0731)が担当しました。

翻訳にあたっては、日本のScalaコミュニティから数多くの貢献を頂きました: [@xuwei-k](http://github.com/xuwei-k)さん、[@kmizu](http://github.com/kmizu)さん、[@eed3si9n](http://github.com/eed3si9n)さん、[@akr4](http://github.com/akr4)さん、[@yosuke-furukawa](http://github.com/yosuke-furukawa)さん、m hanadaさん、および[日本Scalaユーザーズグループ](http://jp.scala-users.org/)の皆さん。（以上、順不同）

また、[@kmizu](http://github.com/kmizu)さんと[@eed3si9n](http://github.com/eed3si9n)さんには、高度に専門的な議論について貴重な助言を頂きました。

ありがとうございます。

[Scala]: http://www.scala-lang.org/
[Finagle]: http://github.com/twitter/finagle
[Util]: http://github.com/twitter/util
