# zlog
A personal blog for the lazy, written purely in Zig, Markdown, and HTML

## Goals:
The goal of this project is a small, simple blog written purely in zig, markdown, and some HTML using some type of static site generation tool. 

There are certainly *much* better ways to perform a blog, but this was my take on it and having some fun with Zig and Zap :)

## Build:

## Adjustments:
You can adjust the base CSS html/styles.css to fit your needs and the 404 page to be what you wish.
Otherwise, the code will generate the rest based on the data in the `posts` folder.

All you must do is add a post and the rest will be created for you :)

## Notes:
1. The name of the file in /posts is the title of the article.
2. Add a timestmap to the article with a comment:
```
<!-- timestamp = 08/17/1996 -->
```
3. Change the nav bar and styles.css to customize the site for your needs
4. Change the 404.html to be whatever you want (unless you love the totally awesome page that currently exists)