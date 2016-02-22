(defproject clojure-core-async "0.1.0-SNAPSHOT"
  :description "Skynet clojure core.async version"
  :url "https://github.com/retrogradeorbit/skynet"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.7.0"]
                 [org.clojure/core.async "0.2.374"]]
  :main ^:skip-aot clojure-core-async.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
