#!/bin/bash

out=target/build
mkdir -p $out
[ -d lib ]             || svn co https://github.com/nqzero/kilim/branches/srl.java8.formdata lib
[ -a lib/kilim.jar ]   || (cd lib; ant clean weave jar)

cp lib/kilim.jar target

find src -name "*.java" | xargs $JAVA_HOME/bin/javac -cp lib/\* -d $out
$JAVA_HOME/bin/java -cp $out:lib/\* kilim.tools.Weaver -d $out $out
$JAVA_HOME/bin/jar cvf target/hello.jar -C $out .

# java -cp target:lib/\* KilimHello




