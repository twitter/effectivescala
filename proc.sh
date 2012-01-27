awk '
/^\.cmd *$/{
	cmd=""
	inshell="yes"
	next
}

/^\.endcmd *$/{
	system(cmd)
	inshell=""
	next
}

{	if(inshell)
		cmd=cmd $0 "\n"
	else
		print
}
'
