SOURCES=src/MVar.hs src/Chan.hs src/Parallel.hs src/Main.hs

All: s
	./s +RTS -N6

s:  ${SOURCES}
	stack ghc -- ${SOURCES} -o s -threaded -O2 -rtsopts -fforce-recomp

clean:
	rm -f ./s ./*.hi ./*.o
