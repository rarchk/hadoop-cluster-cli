# Source : http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-single-node-cluster/

export http_proxy=http://proxy.iiit.ac.in:8080;
export https_proxy=https://proxy.iiit.ac.in:8080;

# hadoop config
export HADOOP_HOME=/opt/hadoop;
export JAVA_HOME=/usr/lib/jvm/jre-1.7.0;

# Convinient hadoop alias
unalias fs &> /dev/null;
alias fs="hadoop fs";
unalias hls &> /dev/null;
alias hls="fs -ls";

# If you have LZO compression enabled in your Hadoop cluster and
# compress job outputs with LZOP (not covered in this tutorial):
# Conveniently inspect an LZOP compressed file from the command
# line; run via:
#
# $ lzohead /hdfs/path/to/lzop/compressed/file.lzo
#
# Requires installed 'lzop' command.
#

lzohead () {
	    hadoop fs -cat $1 | lzop -dc | head -1000 | less;
}

# Add Hadoop bin/ directory to PATH
export PATH=$PATH:$HADOOP_HOME/bin;
