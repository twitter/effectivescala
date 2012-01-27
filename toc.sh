#!/bin/bash

tmp=/tmp/pre$$
trap "rm -f $tmp" 0 1 2 
cat > $tmp

toc=/tmp/toc$$
trap "rm -f $toc" 0 1 2
awk '
function pr(){
	if(!topic) return

	printf "* **<a href=\"#%s\">%s</a>**", topic, topic
	for(i=0; i<t; i++){
		if(i==0) printf ": "
		else printf ", "
		printf "*<a href=\"#%s-%s\">%s</a>*", topic, topics[i], topics[i]
	}
	printf "\n"
}

/^## / {
	pr()
	t=0
	topic=substr($0, 4, length($0)-3)
	delete topics
}
/^### /{
	topics[t++]=substr($0, 5, length($0)-4)
}
END{pr()}
' $tmp > $toc

awk '
/^## /{
	topic=substr($0, 4, length($0)-3)
	print "<a id=\"" topic "\" />"
	print
	next
}
/^### /{
	subtopic=substr($0, 5, length($0)-4)
	printf "<a id=\"%s-%s\" />\n", topic, subtopic
	print
	next
}
{ print $0 }
' $tmp > $tmp.1
mv $tmp.1 $tmp

ed $tmp >/dev/null <<EOF
1
/^\.TOC/r $toc
1
/^\.TOC/d
wq
EOF

cat $tmp
