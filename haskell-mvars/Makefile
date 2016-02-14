skynet: skynet.hs
	ghc -threaded -rtsopts -O3 -o skynet skynet.hs

run: skynet
	./skynet +RTS -N8 -H4G -RTS
