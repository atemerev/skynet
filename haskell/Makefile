SOURCES=src/MVar.hs src/Chan.hs src/Parallel.hs src/Main.hs src/TBQueue.hs src/Unagi.hs

All: s
	./s +RTS -N6

s:  ${SOURCES}
	stack ghc -- ${SOURCES} -o s -threaded -O2 -rtsopts -fforce-recomp

time: s
	./s +RTS -N6

memory: s
	./s +RTS -N6 -T

clean:
	rm -f ./s ./*.hi ./*.o
