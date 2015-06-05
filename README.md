ohi-aster
=========

D3 aster plot visualization for Ocean Health Index

Developed by Parker Abercrombie based on expanded functionality from http://bl.ocks.org/mbostock/3887193.

See live, rendered version here:

http://bl.ocks.org/bbest/2de0e25d4840c68f2db1

![](http://bl.ocks.org/bbest/raw/2de0e25d4840c68f2db1/thumbnail.png)

The nature of loading these JavaScript libraries (and security requirements) requires that you view the index.html through a web server. Viewing it locally, eg via `file://~/github/ohi-aster/index.html` will result in a blank page, related to not being able to find the *.js files. The easiest way I know to get a web server running is using the [Python](https://www.python.org) programming language, which is already included with any modern Mac OS and an easy install on Windows. So you would in Terminal (Mac) or DOS command window (Win), run the following:

```bash
# change directory to this repo's folder
cd ~/github/ohi-aster

# run Python web server
python -m SimpleHTTPServer
```

Then you can visit [http://localhost:8000](http://localhost:8000) to see a functional index.html.

![image](https://cloud.githubusercontent.com/assets/2837257/8017080/ee28f9ba-0ba1-11e5-92e4-caec62563773.png)
