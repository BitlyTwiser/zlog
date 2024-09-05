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

## Notes/Usage:
1. Home/Contact are standard files. You can change these however you like, but do not remove/rename them. :)
2. Adding new blog posts, you must add the link into the `home.md` markdown like so:

```
## Articles

- [Post 1: Test](./test_blog_post_1)
- [Post 2: Building a Static Site Generator](post2.html)
- [Post 3: Exploring Rust and Go](post3.html)

```
This is the only step that is not automatic. I figured, perhaps someone does not want articls and blogs, so I stopped auto injecting things into the home to allow for it to be generic. 
If you hate this, let me know.

3. Provide the title you wish and then just link the markdown location. Everything will be built in (routes etc..)
4. Restart the webserver and all changes/articles etc.. will be present straight away.

## Uniquness:
1. Change the nav bar and styles.css to customize the site for your needs if you so wish
2. Change the 404.html to be whatever you want (unless you love the totally awesome page that currently exists!)

## Bugs:
- Using koino to parse the markdown -> HTML. There seems to be a bug if the first line in the markdown is not a space or other text. (i.e.) you cannot have the first line start with a markdown character like # etc.. else it will break rendering.