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

## 整形

コード*整形*の詳細は、（それが実際的である限りは）重要じゃない。当然だが、スタイルに本質的な良し悪しはないし、たいていは人それぞれの個人的嗜好は異なる。だけど、同じ整形ルールを*一貫して*適用することは、ほぼ全ての場合で可読性を高める。特定のスタイルに馴染んだ読み手は、さらに他のローカルな習慣を理解したり、言語文法の隅っこを解読したりする必要がない。

これは文法の重複度が高いScalaにおいては特に重要だ。メソッド呼び出しを例に挙げよう。メソッドは、"`.`"を付けても、ホワイトスペースを付けても呼び出せる。同様に、ゼロまたは一つの引数を取るメソッドでは丸カッコを付けても良いし、付けなくても良い、といった風に。さらに、異なるスタイルのメソッド呼び出しは、異なる文法上の曖昧さを露呈する！ 注意深く選ばれた整形ルールを一貫して適用することで、人間と機械の両方にとって、多くの曖昧さを解決できるのは間違いない。

我々は、[Scala style guide](http://docs.scala-lang.org/style/)を遵守すると同時に、以下に示すルールを追加した。

### ホワイトスペース

インデントはホワイトスペース2個。100カラムを超える行は避けよう。メソッドやクラス、オブジェクトの定義の間は一行空ける。

### 命名

<dl class="rules">
<dt>小さなスコープでは、短い名前を使う</dt>
<dd> <code>i</code>や<code>j</code>や<code>k</code>は、ループ内ではほとんど期待される。</dd>
<dt>より大きなスコープでは、より長い名前を使う</dt>
<dd>外部APIには、より長く意味のある説明的な名前を付けるべきだ。<code>Future.all</code>ではなく<code>Future.collect</code>のような。
</dd>
<dt>一般的な略語を使い、難解な略語を避ける</dt>
<dd>誰でも<code>ok</code>や<code>err</code>、<code>defn</code>が何を指すか知っている。一方で、<code>sfri</code>はそれほど一般的じゃない。</dd>
<dt>用法が異なるのに名前を再利用しない</dt>
<dd><code>val</code>を使おう。</dd>
<dt>予約名を <code>`</code> を使ってオーバーロードするのは避ける</dt>
<dd><code>`type</code>`の代わりに、<code>typ</code>とする。</dd>
<dt>副作用を伴う操作には動作を表す名前を付ける（訳注：能動態？）</dt>
<dd><code>user.setActive()</code>ではなく、<code>user.activate()</code>とする。</dd>
<dt>値を返すメソッドの名前は説明的に</dt>
<dd><code>src.defined</code>ではなく、<code>src.isDefined</code>とする。</dd>
<dt>getterの接頭に<code>get</code>を付けない</dt>
<dd>以前のルールの通り、これは冗長だ。<code>site.getCount</code>ではなく、<code>site.count</code>とする。</dd>
<dt>パッケージやオブジェクト内で既にカプセル化されている名前を繰り返さない</dt>
<dd><pre><code>object User {
  def getUser(id: Int): Option[User]
}</code></pre>よりも、
<pre><code>object User {
  def get(id: Int): Option[User]
}</code></pre>とする。<code>User.get</code>に比べて、<code>User.getUser</code>は何も情報を提供しないし、使うときに冗長だ。
</dd>
</dl>


### インポート

<dl class="rules">
<dt>インポート行はアルファベット順にソートする</dt>
<dd>こうすることで、視覚的に調べやすいし自動化もしやすい。</dd>
<dt>同じパッケージから複数の名前をインポートするときは中カッコを使う</dt>
<dd><code>import com.twitter.concurrent.{Broker, Offer}</code></dd>
<dt>6つより多くの名前をインポートするときはワイルドカードを使う</dt>
<dd>e.g.: <code>import com.twitter.concurrent._</code>
<br />ワイルドカードを濫用しないこと。一部のパッケージは、大量の名前をエクスポートしている。</dd>
<dt>コレクションを使う時は、<code>scala.collections.immutable</code> あるいは <code>scala.collections.mutable</code> をインポートして名前を修飾する</dt>
<dd>可変(mutable)および不変(immutable)コレクションは、二重に名前を持っている。読み手のために、名前を修飾してどちらのコレクションを使っているのか明らかにしよう。 (e.g. "<code>immutable.Map</code>")</dd>
<dt>他のパッケージからの相対指定でインポートしない</dt>
<dd><pre><code>import com.twitter
import concurrent</code></pre>のようには書かず、以下のように曖昧さの無い書き方をしよう。<pre><code>import com.twitter.concurrent</code></pre></dd>
<dt>インポートはファイルの先頭に置く</dt>
<dd>読み手が、全てのインポートを一箇所で参照できるようにしよう。</dd>
</dl>

### 中カッコ

中カッコは、複合式を作るのに使われる（"モジュール言語"では他の用途にも使われる）。そして、複合式の値は、リスト中の最後の式となる。単純な式に中カッコを使うのは避けよう。例えば、

	def square(x: Int) = x*x
	
.LP と書く代わりに、構文的にメソッドの本体を見分けやすい

	def square(x: Int) = {
	  x * x
	}
	
.LP と書きたいと思うかもしれない。しかし、最初の記法の方が、乱雑さが少なく読みやすい。明確にするのが目的でないなら、<em>構文的な儀礼</em>は避けよう。

### パターンマッチ

適用できる場合は、関数定義の中ではパターンマッチを直接使おう。

	list map { item =>
	  item match {
	    case Some(x) => x
	    case None => default
	  }
	}
	
.LP とする代わりに、matchを折り畳んで

	list map {
	  case Some(x) => x
	  case None => default
	}

.LP と書くと、リストの要素がmapされることが分かりやすい &mdash; the extra indirection does not elucidate. （←？）

### コメント

[ScalaDoc](https://wiki.scala-lang.org/display/SW/Scaladoc)を使ってAPIドキュメントを提供しよう。以下のように書く:

	/**
	 * ServiceBuilder builds services 
	 * ...
	 */
	 
.LP でも標準のScalaDocスタイルは<em>使わない</em>ように:

	/** ServiceBuilder builds services
	 * ...
	 */

アスキーアートや視覚的な装飾に頼ってはいけない。また、APIではない不必要なコメントをドキュメント化してはいけない。もし、自分のコードの挙動を説明するためにコメントを追加しているのに気づいたら、まずは、それが何をするコードなのか明白になるよう書き直せないか考え直してみよう。「見るからに、それは動作する (it works, obviously)」よりも「明らかにそれは動作する(obviously it works)」方が良い（ホーアには申し訳ないけど）。

（訳注: [アントニー・ホーア](http://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%B3%E3%83%88%E3%83%8B%E3%83%BC%E3%83%BB%E3%83%9B%E3%83%BC%E3%82%A2)は、自身のチューリング賞受賞講演の中で、*『極めて複雑に設計して「明らかな」欠陥を無くすより、非常に簡素に設計して「明らかに」欠陥が無いようにする方が遥かに難しい』*という趣旨の発言をしている。「コードから実装の意図を一目瞭然に読み取れるようにせよ」という主張は、上記のホーアの主張の真逆を言っている、ということだろう。）

## 型とジェネリクス

型システムの主な目的は、プログラミングの誤りを検出することだ。型システムは、限定的な方式の静的検査を効果的に提供する。これにより、コンパイラが検証可能なコードにおいて、ある種の不変条件を表現できる。型システムがもたらす恩恵はもちろん他にもあるが、エラーチェックこそ、その存在理由（レーゾンデートル）だ。

我々が型システムを使う場合はこの目的を踏まえるべきだが、一方で、読み手にも気を配り続けなきゃいけない。型を慎重に使ったコードは明瞭さが高まるが、過剰に巧妙に使ったコードは読みにくいだけだ。

Scalaの強力な型システムは、学術的な探求と演習においてよく題材とされる(eg. [Type level programming in
Scala](http://apocalisp.wordpress.com/2010/06/08/type-level-programming-in-scala/))。これらのテクニックは学術的に興味深いトピックだが、プロダクションコードでの応用において有用であることは稀だ。避けるべきだろう。

### 戻り型アノテーション

Scalaでは戻り型アノテーション(return type annotation)を省略できるが、一方でそれらは良いドキュメンテーションであり、publicメソッドでは特に重要だ。露出していないメソッドで、戻り型が明白な場合は省略しよう。

これは、Scalaコンパイラが生成するシングルトン型をミックスインするオブジェクトをインスタンス化する場合は特に重要だ。例えば、`make` 関数が:

	trait Service
	def make() = new Service {
	  def getId = 123
	}

.LP <code>Service</code> という戻り型を<em>持たない</em>場合、コンパイラは細別型(refinement type)である <code>Object with Service{def getId: Int}</code> を生成する。代わりに、明示的なアノテーションを使うと:

	def make(): Service = new Service{}

`make` の公開型を変更することなく、さらに好きなだけtraitをミックスできるから、後方互換性の管理が容易になる。

### 変位

変位(variance)は、ジェネリクスが派生型と結びつく時に現れる。変位は、*コンテナ型*の派生型と、コンテナ型に*含まれる型*の派生型がどう関連するかを定義する。Scalaでは変位アノテーションを宣言できるから、コレクションに代表される共通ライブラリの作者は、多数のアノテーションを扱う必要がある。変位アノテーションは、共用コードの使い勝手を高める上で重要だが、誤用すると危険なものとなりうる。

変位は、Scalaの型システムにおいて、高度だが必須の特徴だ。変位は、派生型の適用を助けるものとして、大いに（そして正しく）使われるべきだ。

*不変コレクションは共変であるべきだ*。要素型を受け取るメソッドは、コレクションを適切に"格下げ"すべきだ:

	trait Collection[+T] {
	  def add[U >: T](other: U): Collection[U]
	}

*可変コレクションは不変であるべきだ*。一般的に、可変コレクションにおいて共変は無効だ。この

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

エイリアスが使える場合は、サブクラスを使ってはいけない。

	trait SocketFactory extends (SocketAddress) => Socket
	
.LP <code>SocketFactory</code>は、<code>Socket</code>を生成する<em>関数</em>だ。型エイリアス

	type SocketFactory = SocketAddress => Socket

.LP を使う方がいい。今や、<code>SocketFactory</code>型の値のための関数リテラルが与えられているので、関数合成を使うことができる:

	val addrToInet: SocketAddress => Long
	val inetToSocket: Long => Socket

	val factory: SocketFactory = addrToInet andThen inetToSocket

パッケージオブジェクトを使うと、型エイリアスをトップレベル名に結びつけられる:

	package com.twitter
	package object net {
	  type SocketFactory = (SocketAddress) => Socket
	}

なお、型エイリアスは、型に対する別名の構文的な代わりとなるものであり、新しい型ではないことに留意しよう。

### 暗黙

暗黙(implicit)は、型システムの強力な機能だが、慎重に使うべきだ。それらの解決ルールは複雑で、シンプルな字句検査においてさえ、実際に何が起きているか把握するのを困難にする。暗黙を間違いなく使ってもいいのは、以下の場面だ:

* Scalaスタイルのコレクションを拡張したり、追加したりするとき
* オブジェクトを適合(adapt)させたり、拡張したりするとき（"pimp my library"パターン）
* [制約エビデンス](http://www.ne.jp/asahi/hishidama/home/tech/scala/generics.html#h_generalized_type_constraints)を提供することで、*型安全を強化*するために使うとき
* 型エビデンス（型クラス）を提供するため
* `Manifest`のため

暗黙を使う場合は、暗黙を使わずに同じことを達成する方法がないか、常に確認しよう。

似通ったデータ型同士を、自動的に変換するのに暗黙を使うのはやめよう（例えば、リストをストリームに変換する等）。型はそれぞれ異なった動作をするので、暗黙に型が変換されていないか、読み手に気を使わせることになる。明示的に変換するべきだ。

## コレクション

Scalaが持つコレクションライブラリは、非常に総称的で、機能豊富で、強力で、組み合わせが容易だ。コレクションは高水準であり、多数の操作を提供している。多数のコレクション操作と変換を簡潔かつ読みやすく表現できるが、それらの機能を不注意に適用すると、しばしば正反対の結果を招く。全てのScalaプログラマは、[collections design document](http://www.scala-lang.org/docu/files/collections-api/collections.html)を読むべきだ。このドキュメントは、Scalaのコレクションライブラリに対する優れた洞察と意欲をもたらしてくれる。

常に、君のニーズを最もシンプルに満たすコレクションを使おう。

### 階層

コレクションライブラリは巨大だ。`Traversable[T]`を基底とする精密な階層に加えて、ほとんどのコレクションに`immutable`と`mutable`のバリエーションがある。複雑さはともかく、以下の図は、`immutable`と`mutable`の双方の階層にとって重要な区別を含んでいる。

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

.LP <code>Iterable[T]</code>はイテレートできるコレクションで、<code>iterator</code>(と<code>foreach</code>)メソッドを提供する。<code>Seq[T]</code>は<em>順序付けされた</em>コレクション、<code>Set[T]</code>は数学的集合（要素が一意な順序の無いコレクション）、そして<code>Map[T]</code>は順序の無い連想配列だ。

### 利用

*不変(immutable)コレクションを利用する。*不変コレクションは、ほとんどの状況に適用できると同時に参照透過なので、プログラムがデフォルトでスレッドセーフであると判断しやすくなる。

*`mutable`名前空間は明示的に使う。*`scala.collections.mutable._`をインポートして`Set`を参照する代わりに、

	import scala.collections.mutable
	val set = mutable.Set()

.LP とすることで、可変な`Set`を使っていることが分かりやすくなる。

*コレクション型のデフォルトコンストラクタを使う。*例えば、順序付きの（かつ連結リストの動作が必要ない）シーケンスが欲しい場合は、いつでも`Seq()`コンストラクタを使おう:

	val seq = Seq(1, 2, 3)
	val set = Set(1, 2, 3)
	val map = Map(1 -> "one", 2 -> "two", 3 -> "three")

.LP このスタイルでは、コレクションの動作がその実装と切り離されているので、コレクションライブラリは最も適切な実装型を使うことができる。君が必要としているのは<code>Map</code>であって、必ずしも赤黒木じゃない。さらに、これらのデフォルトコンストラクタは、しばしば特殊化した表現を用いる。例えば<code>Map()</code>は、3つのキーを持つマップに対して、3つのフィールドを持つオブジェクトを使う（訳注: [Map3](http://www.scala-lang.org/api/current/scala/collection/immutable/Map$$Map3.html)クラスのこと）。

以上からの結論として、メソッドやコンストラクタでは、*最も総称的なコレクション型を適切に受け取ろう*。これは詰まるところ、通常は上記の`Iterable`、`Seq`、`Set`あるいは`Map`のうち、どれか一つである。もしメソッドがシーケンスを必要とする場合は、`List[T]`ではなく`Seq[T]`を使おう。

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

性能最適化の第一法則は、君のアプリケーションが*なぜ*遅いのかを理解することだ。最適化を始める前に、君のアプリケーションをプロファイル^[[Yourkit](http://yourkit.com)は良いプロファイラだ。]してデータを取ろう。最初に注目するのは、回数の多いループや巨大なデータ構造だ。最適化への過度な取り組みは、たいてい無駄な努力に終わる。クヌースの「時期尚早な最適化は諸悪の根源」という格言を思い出そう。

性能やメモリ使用効率の良さが要求される場面では、多くの場合、低レベルコレクションを使うのが妥当だ。巨大なシーケンスには、リストより配列を使おう（不変の`Vector`コレクションは、配列への参照透過なインタフェースを提供する）。また、性能が重要な場合は、シーケンスを直接生成せずにバッファを使おう。

### Javaコレクション

Javaコレクションとの相互運用のために、`scala.collection.JavaConverters`を使おう。`JavaConverters`は、暗黙変換を行う`asJava`メソッドと`asScala`メソッドを追加する。読み手を助けるために、これらの変換は明示的に行うようにしよう:

	import scala.collection.JavaConverters._
	
	val list: java.util.List[Int] = Seq(1,2,3,4).asJava
	val buffer: scala.collection.mutable.Buffer[Int] = list.asScala

## 並行性

現代のサービスは、サーバへの何万何十万もの同時操作を調整するため、高い並行性を備えている。そして、隠れた複雑性への対処は、堅固なシステムソフトウェアを記述する上で中心的なテーマだ。

*スレッド*は、並行性を表現する一つの手段だ。スレッドからは、OSがスケジュールする、ヒープを共有する独立した実行コンテクストを利用できる。しかし、Javaにおいてスレッド生成はコストが高い。そのため、主にスレッドプールを使って、リソースとして管理する必要がある。これは、プログラマにとってさらなる複雑さを生み出す。また、アプリケーションロジックとそれが使用する潜在的なリソースを分離するのが難しくなり、結合度を高めてしまう。

この複雑さは、出力の大きいサービスの製作において、とりわけ明らかになる。それぞれの受信リクエストからは、システムのまた別の階層に対する多数のリクエストが生じる。それらのシステムにおいて、スレッドプールは、各階層でのリクエストの割合によってバランスするよう管理されなきゃならない。あるスレッドプールで管理に失敗すると、その影響は他のスレッドプールにも広がってしまう。

また、堅固なシステムは、タイムアウトとキャンセルについても検討する必要がある。どちらに対処するにも、さらなる「制御スレッド」の導入が必要で、そのことが問題をさらに複雑にする。ちなみに、もしスレッドのコストが安いなら、こうした問題は少なくなる。なぜなら、スレッドプールが必要とされず、タイムアウトスレッドを切り捨てることができ、追加のリソース管理も必要ないからだ。

このように、リソース管理はモジュール性を危うくするのだ。

### Future

Futureを使って並行性を管理しよう。Futureは、並行操作とリソース管理を疎結合にする。例えば、[Finagle][Finagle]は、並行操作をわずかなスレッド数で効率的に多重化する。Scalaには、軽量なクロージャリテラルの構文がある。だから、Futureは構文上の負担が小さく、ほとんどのプログラマが身に付けることができる。

Futureは、プログラマが並行計算を宣言的なスタイルで表現できるようにする。Futureは組み立て可能で、また計算の失敗を原則に沿って処理できる。こうした性質から、Futureは関数型プログラミング言語にとても適しており、推奨されるスタイルだと確信している。

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

不変(immutable)コレクションで目的を果たせるなら、それを使おう。不変コレクションは参照透過なので、並行コンテキストでの推論が簡単になる。不変コレクションの変更は、主に（`var`セルや`AtomicReference`が指す）現在の値への参照を更新することで行う。不変コレクションの変更を適用する際は、注意が必要だ。他のスレッドへ不変コレクションを公開する場合、`AtomicReference`には再試行が必要だし、`var`変数は`volatile`として宣言しなければいけない。

可変(mutable)な並行コレクションは複雑な動作をするだけでなく、Javaメモリモデルの微妙な部分を利用する。だから、可変並行コレクションが更新を公開する方法など、暗黙的な挙動について理解しておこう。また、コレクションの合成には同期化コレクションを使おう。並行コレクションでは、`getOrElseUpdate`のような操作を正しく実装できないし、特に、合成コレクションの作成はエラーの温床だ。

<!--

use the stupid collections first, get fancy only when justified.

serialized? synchronized?

blah blah.

Async*?

-->


## 制御構造

関数型スタイルで書くプログラムは、宣言型スタイルで書く場合より伝統的な制御構造が少なく済むことが多く、また読みやすい。関数型スタイルとは、典型的には、ロジックをいくつかの小さなメソッドや関数に分解し、それらを互いに`match`式で貼り合わせることを意味する。また、関数型プログラムは、より式指向となる傾向がある。つまり、条件式の分岐で同じ型の値を計算し、`for (..) yield`で内包(comprehension)を計算する。また、再帰を一般的に利用する。

### 再帰

*再帰表現を使うと、問題をしばしば簡潔に記述できる。*そしてコンパイラは、末尾呼び出しの最適化が適用できるコードを、正規のループに置き換える（末尾最適化が適用されるかは`@tailrec`アノテーションで確認できる）。

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

.LP ここでは、すべての反復ははっきりと<em>白紙の状態で</em>開始される。また、参照セルが存在しないため、不変条件を数多く見出せる。このコードはより推論しやすいだけでなく、より読みやすい。それだけでなく、性能面のペナルティもない。コンパイラはメソッドが末尾再帰なら、これを標準的な命令型のループへと変換するからだ。

（訳注: [エドガー・ダイクストラ](http://ja.wikipedia.org/wiki/%E3%82%A8%E3%83%89%E3%82%AC%E3%83%BC%E3%83%BB%E3%83%80%E3%82%A4%E3%82%AF%E3%82%B9%E3%83%88%E3%83%A9)は、構造化プログラミングの提唱者。彼が執筆したエッセイ"Go To Statement Considered Harmful"は、「GOTO有害論」の端緒として有名。）

<!--
elaborate..
-->


### Return

前節では再帰を使うメリットを紹介したが、これは「命令型の構造は無価値だ」と言いたいわけじゃない。ほとんどの場合、計算を早期に打ち切る方が、終点の可能性がある全ての位置に条件分岐を持つよりも適切だ。実際に、上記の`fixDown`は、ヒープの終端に達すると`return`によって早期に終了する。

`return`を使うと、分岐を省略して不変条件を確立できる。これにより、入れ子が減って読みやすくなるだけでなく、後続のコードの正当性を論証しやすくなる（配列の範囲外をアクセスしないことを確認する場合とか）。これは、"ガード節"で特に有用だ:

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
	
.LP このコードは、バイトコードでは例外の`throw`と`catch`として実装されるので、実行頻度の高いコードで使うと、性能に影響を与える。

### `for`ループと内包

`for`を使うと、ループと集約を簡潔かつ自然に表現できる。`for`は、多数のシーケンスを平坦化する場合に特に有用だ。`for`の構文は、内部的にはクロージャを割り当てて呼び出していることを覆い隠している。このため、予期しないコストが発生したり、予想外の挙動を示したりする。例えば、

	for (item <- container) {
	  if (item != 2) return
	}

.LP このコードでは、<code>return</code>を非局所的(nonlocal)にするよう`container`が計算を遅延させると、ランタイムエラーが発生することがある！（訳注: どういう意味？）

これらの理由から、コードを明瞭にするためである場合を除いて、`for`を使う代わりに、`foreach`や`flatMap`や`map`や`filter`を直接呼び出す方が良いことが多い。

### `require`と`assert`

`require`と`assert`は、どちらも実行可能なドキュメントとして機能する。これらは、要求される不変条件を型システムが表現できない状況で有用だ。`assert`は、コードが仮定する（内部あるいは外部の）*不変条件*を表現するために使われる。例えば、

	val stream = getClass.getResourceAsStream("someclassdata")
	assert(stream != null)

一方で、`require`はAPIの契約を表現するために使われる:

	def fib(n: Int) = {
	  require(n > 0)
	  ...
	}

## Functional programming

*Value oriented* programming confers many advantages, especially when
used in conjunction with functional programming constructs. This style
emphasizes the transformation of values over stateful mutation,
yielding code that is referentially transparent, providing stronger
invariants and thus also easier to reason about. Case classes, pattern
matching, destructuring bindings, type inference, and lightweight
closure and method creation syntax are the tools of this trade.

### Case classes as algebraic data types

Case classes encode ADTs: they are useful for modelling a large number
of data structures and provide for succinct code with strong
invariants, especially when used in conjunction with pattern matching.
The pattern matcher implements exhaustivity analysis providing even
stronger static guarantees.

Use the following pattern when encoding ADTs with case classes:

	sealed trait Tree[T]
	case class Node[T](left: Tree[T], right: Tree[T]) extends Tree[T]
	case class Leaf[T](value: T) extends Tree[T]
	
.LP the type <code>Tree[T]</code> has two constructors: <code>Node</code> and <code>Leaf</code>. Declaring the type <code>sealed</code> allows the compiler to do exhaustivity analysis since constructors cannot be added outside the source file.

Together with pattern matching, such modelling results in code that is
both succinct "obviously correct":

	def findMin[T <: Ordered[T]](tree: Tree[T]) = tree match {
	  case Node(left, right) => Seq(findMin(left), findMin(right)).min
	  case Leaf(value) => value
	}

While recursive structures like trees constitute classic applications of
ADTs, their domain of usefulness is much larger. Disjoint unions in particular are
readily modelled with ADTs; these occur frequently in state machines.

### Options

The `Option` type is a container that is either empty (`None`) or full
(`Some(value)`). They provide a safe alternative to the use of `null`,
and should be used in their stead whenever possible. They are a 
collection (of at most one item) and they are embellished with 
collection operations -- use them!

Write

	var username: Option[String] = None
	...
	username = Some("foobar")
	
.LP instead of

	var username: String = null
	...
	username = "foobar"
	
.LP since the former is safer: the <code>Option</code> type statically enforces that <code>username</code> must be checked for emptyness.

Conditional execution on an `Option` value should be done with
`foreach`; instead of

	if (opt.isDefined)
	  operate(opt.get)

.LP write

	opt foreach { value =>
	  operate(value)
	}

The style may seem odd, but provides greater safety (we don't call the
exceptional `get`) and brevity. If both branches are taken, use
pattern matching:

	opt match {
	  case Some(value) => operate(value)
	  case None => defaultAction()
	}

.LP but if all that's missing is a default value, use <code>getOrElse</code>

	operate(opt getOrElse defaultValue)
	
Do not overuse  `Option`: if there is a sensible
default -- a [*Null Object*](http://en.wikipedia.org/wiki/Null_Object_pattern) -- use that instead.

`Option` also comes with a handy constructor for wrapping nullable values:

	Option(getClass.getResourceAsStream("foo"))
	
.LP is an <code>Option[InputStream]</code> that assumes a value of <code>None</code> should <code>getResourceAsStream</code> return <code>null</code>.

### Pattern matching

Pattern matches (`x match { ...`) are pervasive in well written Scala
code: they conflate conditional execution, destructuring, and casting
into one construct. Used well they enhance both clarity and safety.

Use pattern matching to implement type switches:

	obj match {
	  case str: String => ...
	  case addr: SocketAddress => ...

Pattern matching works best when also combined with destructuring (for
example if you are matching case classes); instead of

	animal match {
	  case dog: Dog => "dog (%s)".format(dog.breed)
	  case _ => animal.species
	  }

.LP write

	animal match {
	  case Dog(breed) => "dog (%s)".format(breed)
	  case other => other.species
	}

Write [custom extractors](http://www.scala-lang.org/node/112) but only with
a dual constructor (`apply`), otherwise their use may be out of place.

Don't use pattern matching for conditional execution when defaults
make more sense. The collections libraries usually provide methods
that return `Option`s; avoid

	val x = list match {
	  case head :: _ => head
	  case Nil => default
	}

.LP because

	val x = list.headOption getOrElse default

.LP is both shorter and communicates purpose.

### Partial functions

Scala provides syntactical shorthand for defining a `PartialFunction`:

	val pf: PartialFunction[Int, String] = {
	  case i if i%2 == 0 => "even"
	}
	
.LP and they may be composed with <code>orElse</code>

	val tf: (Int => String) = pf orElse { case _ => "odd"}
	
	tf(1) == "odd"
	tf(2) == "even"

Partial functions arise in many situations and are effectively
encoded with `PartialFunction`, for example as arguments to
methods

	trait Publisher[T] {
	  def subscribe(f: PartialFunction[T, Unit])
	}

	val publisher: Publisher[Int] = ..
	publisher.subscribe {
	  case i if isPrime(i) => println("found prime", i)
	  case i if i%2 == 0 => count += 2
	  /* ignore the rest */
	}

.LP or in situations that might otherwise call for returning an <code>Option</code>:

	// Attempt to classify the the throwable for logging.
	type Classifier = Throwable => Option[java.util.logging.Level]

.LP might be better expressed with a <code>PartialFunction</code>

	type Classifier = PartialFunction[Throwable, java.util.Logging.Level]
	
.LP as it affords greater composability:

	val classifier1: Classifier
	val classifier2: Classifier

	val classifier = classifier1 orElse classifier2 orElse { _ => java.util.Logging.Level.FINEST }


### Destructuring bindings

Destructuring value bindings are related to pattern matching; they use the same
mechanism but are applicable when there is exactly one option (lest you accept
the possibility of an exception). Destructuring binds are particularly useful for
tuples and case classes.

	val tuple = ('a', 1)
	val (char, digit) = tuple
	
	val tweet = Tweet("just tweeting", Time.now)
	val Tweet(text, timestamp) = tweet

### Lazyness

Fields in scala are computed *by need* when `val` is prefixed with
`lazy`. Because fields and methods are equivalent in Scala (lest the fields
are `private[this]`)

	lazy val field = computation()

.LP is (roughly) short-hand for

	var _theField = None
	def field = if (_theField.isDefined) _theField.get else {
	  _theField = Some(computation())
	  _theField.get
	}

.LP i.e., it computes a results and memoizes it. Use lazy fields for this purpose, but avoid using lazyness when lazyness is required by semantics. In these cases it's better to be explicit since it makes the cost model explicit, and side effects can be controlled more precisely.

Lazy fields are thread safe.

### Call by name

Method parameters may be specified by-name, meaning the parameter is
bound not to a value but to a *computation* that may be repeated. This
feature must be applied with care; a caller expecting by-value
semantics will be surprised. The motivation for this feature is to
construct syntactically natural DSLs -- new control constructs in
particular can be made to look much like native language features.

Only use call-by-name for such control constructs, where it is obvious
to the caller that what is being passed in is a "block" rather than
the result of an unsuspecting computation. Only use call-by-name arguments
in the last position of the last argument list. When using call-by-name,
ensure that method is named so that it is obvious to the caller that 
its argument is call-by-name.

When you do want a value to be computed multiple times, and especially
when this computation is side effecting, use explicit functions:

	class SSLConnector(mkEngine: () => SSLEngine)
	
.LP The intent remains obvious and caller is left without surprises.

### `flatMap`

`flatMap` -- the combination of `map` with `flatten` -- deserves special
attention, for it has subtle power and great utility. Like its brethren `map`, it is frequently
available in nontraditional collections such as `Future` and `Option`. Its behavior
is revealed by its signature; for some `Container[A]`

	flatMap[B](f: A => Container[B]): Container[B]

.LP <code>flatMap</code> invokes the function <code>f</code> for the element(s) of the collection producing a <em>new</em> collection, (all of) which are flattened into its result. For example, to get all permutations of two character strings that aren't the same character repeated twice:

	val chars = 'a' to 'z'
	val perms = chars flatMap { a => 
	  chars flatMap { b => 
	    if (a != b) Seq("%c%c".format(a, b)) 
	    else Seq() 
	  }
	}

.LP which is equivalent to the more concise for-comprehension (which is &mdash; roughly &mdash; syntactical sugar for the above):

	val perms = for {
	  a <- chars
	  b <- chars
	  if a != b
	} yield "%c%c".format(a, b)

`flatMap` is frequently useful when dealing with `Options` -- it will
collapse chains of options down to one,

	val host: Option[String] = ..
	val port: Option[Int] = ..
	
	val addr: Option[InetSocketAddress] =
	  host flatMap { h =>
	    port map { p =>
	      new InetSocketAddress(h, p)
	    }
	  }

.LP which is also made more succinct with <code>for</code>

	val addr: Option[InetSocketAddress] = for {
	  h <- host
	  p <- port
	} yield new InetSocketAddress(h, p)

The use of `flatMap` in `Future`s is discussed in the 
<a href="#Twitter's%20standard%20libraries-Futures">futures section</a>.

## オブジェクト指向プログラミング

Scala の広大さの多くはオブジェクト機構にある。Scala は、*すべての値が*オブジェクトであるという意味で、*純粋な* 言語である。プリミティブな型と混合型の間に違いはない。 Scala はミックスインの機能もあり、静的型チェックの利益をすべて享受しつつ、もっと直行して別々なモジュールをコンパイル時に柔軟に一緒に組立てができる。

ミックスイン機構の背景ある動機は、伝統的な依存性注入の必要性を不要にするためにある。その"コンポーネントスタイル"のプログラミングの最高点は、[ Cake
パターン](http://jboner.github.com/2008/10/06/real-world-scala-dependency-injection-di.html) である。

### 依存性注入

私たちの利用では、しかし、Scala それ自身が、”クラシックな”(コンストラクタによる)依存性注入の多くの構文上のオーバーヘッドは、むしろそれを使う。それはより明快であり、依存性は(コンストラクタの)型でまだエンコードされ、クラスの組立は、とても構文的に些細であり、そよ風くらいになる。

それは退屈でシンプルだが動作する。*プログラムのモジュール化のために依存性注入を使うこと*。特に、*継承より合成を選択すること* 。 これにより、もっとモジュール化が進みテスト可能なプログラムになる。継承が必要な状況に遭遇した時、自分自身に問うのだ：もし言語が継承をサポートしていなかったら、どのように構造化するだろう、と。この答えは強いることができるかもしれない。

依存性注入は典型的にはトレイトを利用する。

     trait TweetStream {
       def subscribe(f: Tweet => Unit)
     }
     class HosebirdStream extends TweetStream ...
     class FileStream extends TweetStream ..

     class TweetCounter(stream: TweetStream) {
       stream.subscribe { tweet => count += 1 }
     }

*ファクトリー*(オブジェクトを生成するオブジェクト)を注入することは一般的である。これら(下記のような？？)のケースでは、特化したファクトリー型よりはシンプルな関数の利用を好むようにする。

     class FilteredTweetCounter(mkStream: Filter => TweetStream) {
       mkStream(PublicTweets).subscribe { tweet => publicCount += 1 }
       mkStream(DMs).subscribe { tweet => dmCount += 1 }
     }

### トレイト

依存性注入は、一般的な*インターフェイス*の利用や、トレイトで共通のコードを実装することを妨げるものでは全くない。全く反対なのだが、トレイトの利用は次の理由で強く推奨されている：複数のインターフェイス(トレイト)は、具象クラスで実装されるかもしれないし、共通コードはすべてのそれらのクラス群に横断的に再利用されるかもしれない。

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

.LP そして、もともと<code>IOer</code> だったこれらをミックスしてみる: <code>new Reader with Writer</code>&hellip;  インターフェイスの最小化は、よりよい直交性とよりよりモジュール化につながる。

### 可視性

Scala は非常に表現豊かな可視性の修飾子を持つ。修飾子は、何を*公開API*として構成するかを定義するのに重要である。公開APIは限定されるべきであり、それにより利用者は不注意に実装の詳細に依存することはなく、また、作者のAPIを変更する力を制限する。このことは、良いモジュール性にとって決定的に重要である。ルールとして、公開APIを拡張することは、彼らと契約するよりもかなり簡単である。貧相なアノテーションは、君のコードの後方バイナリ互換性を汚すこともできるようにもなる。


#### `private[this]`

`private` にしたクラスメンバーは、

     private val x: Int = ...

.LP そのクラスの(しかし、サブクラスは含まずに)すべての<em>インスタンス</em>から見える。殆どの場合、君は<code>private[this]</code>としたいだろう。

     private[this] val: Int = ..

.LP これは特定のインスタンスに可視性を制限する。Scala コンパイラーは、<code>private[this]</code> を(アクセスが静的に定義されたクラスに限られるから)シンプルなフィールドアクセッサに変換することもでき、それは時々、性能を最適化することに寄与する。

#### シングルトンクラス型(？正確な訳？)

Scala では、シングルトンクラス型を生成するのは一般的である。例えば、

     def foo() = new Foo with Bar with Baz {
       ...
     }

.LP このような状況では、戻り型を宣言することで可視性は限定される。

     def foo(): Foo with Bar = new Foo with Bar with Baz {
       ...
     }

.LP <code>foo()</code> の呼び出し側は、戻されたインスタンスの限定されたビュー(<code>Foo with Bar</code>) が参照できる

### 構造的型(？正確な訳？)

通常の使用では構造的型は使わない。構造的型は、便利で強力な機能であるが、残念あんことにJVM上では効率的な実装手段はない。しかし、ある運命のいたずらともいうべき実装によって、リフレクションをするためのとても良い速記法を提供する。

     val obj: AnyRef
     obj.asInstanceOf[{def close()}].close()

## ガベージコレクション

我々は、運用時にガベージコレクションのチューニングに多くの時間を費やす。
ガベージコレクションの考慮事項はかなりJavaのそれに似ているが、典型的な Scala コードの場合は 典型的な Java コードより多くの(生存時間の短い)ガベージを生成する。これは関数スタイルの副作用なのである。HotSpot の世代別ガベージコレクションは、ほとんどの環境では生存時間の短いガベージを効果的に解放するので、概してこれは問題にならない。

GCの性能問題に取り組む前に、Attila が発表した我々のGCチューニングに関する経験のいくつかに関する[プレゼンテーション](http://www.infoq.com/presentations/JVM-Performance-Tuning-twitter)を見て欲しい。


Scala 固有で、GC問題を軽減する唯一のツールは、ガベージの生成をより少なくすることである。しかし、データなしで行動してはならない！もし、明らかに悪化させる何かをしているわけではないのであれば、我々の提供する [heapster](https://github.com/mariusaeriksen/heapster) や
[gcprof](https://github.com/twitter/jvmgcprof) を含む、Java の様々なプロファイルツールを使うことだ。

## Java 互換性

我々は、Scala コードをJavaで利用するとき、Javaでの使い方を慣用的に残して良いものか確かめるようにしている。大体は余計な努力は必要ない。クラス群と実装を含まないトレイトはJava に正確に等価に対応される。しかし、時々、別にJava APIを提供する必要がある。あなたのライブラリのJava API の感じをつかむ良い方法は単体テストをJavaで書くことである(ただコンパイルが通れば良い)。この点については Scala コンパイラーは不安定であるのだが、このテストによって、あなたのライブラリの Java 視点は安定さを維持できる。

実装を含むトレイトは直接 Java から利用できない。代わりに抽象クラスをトレイトと共に拡張する必要がある。

     // 直接 Java から利用できない
     trait Animal {
       def eat(other: Animal)
       def eatMany(animals: Seq[Animal) = animals foreach(eat(_))
     }

     // しかし、これはできる
     abstract class JavaAnimal extends Animal

## Twitter's standard libraries

The most important standard libraries at Twitter are
[Util](http://github.com/twitter/util) and
[Finagle](https://github.com/twitter/finagle). Util should be
considered an extension to the Scala and Java standard libraries, 
providing missing functionality or more appropriate implementations. Finagle
is our RPC system; the kernel distributed systems components.

### Futures

Futures have been <a href="#Concurrency-Futures">discussed</a>
briefly in the <a href="#Concurrency">concurrency section</a>. They 
are the central mechanism for coordination asynchronous
processes and are pervasive in our codebase and core to Finagle.
Futures allow for the composition of concurrent events, and simplifies
reasoning about highly concurrent operations. They also lend themselves
to a highly efficient implementation on the JVM.

Twitter's futures are *asynchronous*, so blocking operations --
basically any operation that can suspend the execution of its thread;
network IO and disk IO are examples -- must be handled by a system
that itself provides futures for the results of said operations.
Finagle provides such a system for network IO.

Futures are plain and simple: they hold the *promise* for the result
of a computation that is not yet complete. They are a simple container
-- a placeholder. A computation could fail of course, and this must 
also be encoded: a Future can be in exactly one of 3 states: *pending*,
*failed* or *completed*.

<div class="explainer">
<h3>Aside: <em>Composition</em></h3>
<p>Let's revisit what we mean by composition: combining simpler components
into more complicated ones. The canonical example of this is function
composition: Given functions <em>f</em> and
<em>g</em>, the composite function <em>(g&#8728;f)(x) = g(f(x))</em> &mdash; the result
of applying <em>x</em> to <em>f</em> first, and then the result of that
to <em>g</em> &mdash; can be written in Scala:</p>

<pre><code>val f = (i: Int) => i.toString
val g = (s: String) => s+s+s
val h = g compose f  // : Int => String
	
scala> h(123)
res0: java.lang.String = 123123123</code></pre>

.LP the function <em>h</em> being the composite. It is a <em>new</em> function that combines both <em>f</em> and <em>g</em> in a predefined way.
</div>

Futures are a type of collection -- they are a container of
either 0 or 1 elements -- and you'll find they have standard 
collection methods (eg. `map`, `filter`, and `foreach`). Since a Future's
value is deferred, the result of applying any of these methods
is necessarily also deferred; in

	val result: Future[Int]
	val resultStr: Future[String] = result map { i => i.toString }

.LP the function <code>{ i => i.toString }</code> is not invoked until the integer value becomes available, and the transformed collection <code>resultStr</code> is also in pending state until that time.

Lists can be flattened;

	val listOfList: List[List[Int]] = ..
	val list: List[Int] = listOfList.flatten

.LP and this makes sense for futures, too:

	val futureOfFuture: Future[Future[Int]] = ..
	val future: Future[Int] = futureOfFuture.flatten

.LP since futures are deferred, the implementation of <code>flatten</code> &mdash; it returns immediately &mdash; has to return a future that is the result of waiting for the completion of the outer future (<code><b>Future[</b>Future[Int]<b>]</b></code>) and after that the inner one (<code>Future[<b>Future[Int]</b>]</code>). If the outer future fails, the flattened future must also fail.

Futures (like Lists) also define `flatMap`; `Future[A]` defines its signature as

	flatMap[B](f: A => Future[B]): Future[B]
	
.LP which is like the combination of both <code>map</code> and <code>flatten</code>, and we could implement it that way:

	def flatMap[B](f: A => Future[B]): Future[B] = {
	  val mapped: Future[Future[B]] = this map f
	  val flattened: Future[B] = mapped.flatten
	  flattened
	}

This is a powerful combination! With `flatMap` we can define a Future that
is the result of two futures sequenced, the second future computed based
on the result of the first one. Imagine we needed to do two RPCs in order
to authenticate a user (id), we could define the composite operation in the
following way:

	def getUser(id: Int): Future[User]
	def authenticate(user: User): Future[Boolean]
	
	def isIdAuthed(id: Int): Future[Boolean] = 
	  getUser(id) flatMap { user => authenticate(user) }

.LP an additional benefit to this type of composition is that error handling is built-in: the future returned from <code>isAuthed(..)</code> will fail if either of <code>getUser(..)</code> or <code>authenticate(..)</code> does with no extra error handling code.

#### Style

Future callback methods (`respond`, `onSuccess', `onFailure`, `ensure`)
return a new future that is *chained* to its parent. This future is guaranteed
to be completed only after its parent, enabling patterns like

	acquireResource()
	future onSuccess { value =>
	  computeSomething(value)
	} ensure {
	  freeResource()
	}

.LP where <code>freeResource()</code> is guaranteed to be executed only after <code>computeSomething</code>, allowing for emulation of the native <code>try .. finally</code> pattern.

Use `onSuccess` instead of `foreach` -- it is symmetrical to `onFailure` and
is a better name for the purpose, and also allows for chaining.

Always try to avoid creating your own `Promise`s: nearly every task
can be accomplished via the use of predefined combinators. These
combinators ensure errors and cancellations are propagated, and generally
encourage *dataflow style* programming which usually <a
href="#Concurrency-Futures">obviates the need for synchronization and
volatility declarations</a>.

Code written in tail-recursive style are not subject so space leaks,
allowing for efficient implementation of loops in dataflow-style:

	case class Node(parent: Option[Node], ...)
	def getNode(id: Int): Future[Node] = ...

	def getHierarchy(id: Int, nodes: List[Node] = Nil): Future[Node] =
	  getNode(id) flatMap {
	    case n@Node(Some(parent), ..) => getHierarchy(parent, n :: nodes)
	    case n => Future.value((n :: nodes).reverse)
	  }

`Future` defines many useful methods: Use `Future.value()` and
`Future.exception()` to create pre-satisfied futures.
`Future.collect()`, `Future.join()` and `Future.select()` provide
combinators that turn many futures into one (ie. the gather part of a
scatter-gather operation).

#### Cancellation

Futures implement a weak form of cancellation. Invoking `Future#cancel`
does not directly terminate the computation but instead propagates a
level triggered *signal* that may be queried by whichever process
ultimately satisfies the future. Cancellation flows in the opposite
direction from values: a cancellation signal set by a consumer is
propagated to its producer. The producer uses `onCancellation` on
`Promise` to listen to this signal and act accordingly.

This means that the cancellation semantics depend on the producer,
and there is no default implementation. *Cancellation is a but a hint*.

#### Locals

Util's
[`Local`](https://github.com/twitter/util/blob/master/util-core/src/main/scala/com/twitter/util/Local.scala#L40)
provides a reference cell that is local to a particular future dispatch tree. Setting the value of a local makes this
value available to any computation deferred by a Future in the same thread. They are analagous to thread locals,
except their scope is not a Java thread but a tree of "future threads". In

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

.LP <code>user()</code> in the <code>ensure</code> block will refer to the value of the <code>user</code> local at the time the callback was added.

As with thread locals, `Local`s can be very convenient, but should
almost always be avoided: make sure the problem cannot be sufficiently
solved by passing data around explicitly, even if it is somewhat
burdensome.

Locals are used effectively by core libraries for *very* common 
concerns -- threading through RPC traces, propagating monitors,
creating "stack traces" for future callbacks -- where any other solution
would unduly burden the user. Locals are inappropriate in almost any
other situation.

<!--
  ### Offer/Broker

-->

## Acknowledgments

The lessons herein are those of Twitter's Scala community -- I hope
I've been a faithful chronicler.

Blake Matheny, Nick Kallen, and Steve Gury provided much helpful
guidance and many excellent suggestions.

[Scala]: http://www.scala-lang.org/
[Finagle]: http://github.com/twitter/finagle
[Util]: http://github.com/twitter/util
