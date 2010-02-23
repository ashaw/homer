# Homer

Homer makes homepages. 

## Rationale

Blogware is good for storing content and metadata. All blogware keeps track of the most [basic fields necessary](http://en.wikipedia.org/wiki/Blog_software#Post_and_comment_management) to tell a story: a title, a body, a creation date and a permalink. Blogware is excellent for presenting this data in one manner: reverse cron. Deviation from the classic format is, at best, frustrating, and at worst impossible. Yet, everyone uses and loves blogware. So much so, that they want to use it for everything, including to create *hierarchical*, rather than chronological front pages. So **why not let blogware handle what it's best at-- storing core data fields**, and have another tool specifically for handling homepages. Hence, Homer: Homepage creator. 

## How?

All blogware provides at least one form of syndication: RSS, Atom, etc. Let's parse those feeds, and create lists of stories so you can select where each story should live on a hierarchical front page. Let's also let you style your front page however you want, create the number of "slots" you want, and let Homer figure out how to assign your stories to slots. Let's be blogware-agnostic, and even friendly to multiple backends and sources. Let's have sensible defaults, but total customization.

## Installation & Usage

Homer is now ready for soft alpha testing. To install, first make sure you have the following gems installed: 

* sinatra >= 0.9, < 1 
* active_record >= 2.3.4, < 3.0
* sqlite3-ruby 
* [feedme](http://rubygems.org/gems/feedme)

then

* `git clone git://github.com/ashaw/homer.git`
* `cd homer/bin`
* `ruby homer init` (to set up SQLite db)
* `ruby homer run`
* open a browser to http://localhost:4567

Bugs & suggestions welcome via the [Issues](http://github.com/ashaw/homer/issues) area. Blog post and screencast on usage forthcoming. 

## License (MIT)

Copyright (c) 2010 Al Shaw

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.