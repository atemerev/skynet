(ns clojure-core-async.core
  (:require [clojure.core.async :refer [go <! <!!]]))

(defn skynet [num size div]
  (go
    (if (= 1 size) num
        (let [factor (/ size div)]
          (loop [sum 0 [c & rem] (->> div range
                                      (map #(skynet (+ num (* % factor)) factor div)))]
            (if (nil? c) sum
                (recur (+ sum (<! c)) rem)))))))

(defn -main  [& args]
  (-> (skynet 0 1000000 10) <!! time println))
