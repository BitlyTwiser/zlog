
### CSS for Styling (Using a `<style>` tag in Markdown-rendered HTML)

<!-- Menu Bar -->
<nav style="background-color: #3498db; padding: 15px; text-align: center;">
    <a href="index.html" style="color: white; text-decoration: none; font-size: 1.2em; margin: 0 15px;">Home</a>
    <a href="features.html" style="color: white; text-decoration: none; font-size: 1.2em; margin: 0 15px;">Features</a>
    <a href="blog.html" style="color: white; text-decoration: none; font-size: 1.2em; margin: 0 15px;">Blog</a>
    <a href="contact.html" style="color: white; text-decoration: none; font-size: 1.2em; margin: 0 15px;">Contact</a>
</nav>

# Welcome to My Blog

Welcome to the homepage of my personal blog! Here, you'll find various posts on tech, programming, and more.

## Latest Blog Posts

- [Post 1: Getting Started with Zig](post1.html)
- [Post 2: Building a Static Site Generator](post2.html)
- [Post 3: Exploring Rust and Go](post3.html)

---

Thank you for visiting my blog! Feel free to explore more content through the menu bar above.


<style>
    /* Body Styling */
    body {
        font-family: 'Roboto', sans-serif;
        line-height: 1.6;
        background-color: #f5f5f5;
        color: #333;
        padding: 20px;
    }

    /* Headers */
    h1, h2, h3 {
        color: #2c3e50;
        text-align: center;
    }

    h1 {
        font-size: 3rem;
        font-weight: 700;
        text-transform: uppercase;
        margin-bottom: 20px;
        color: #3498db;
        letter-spacing: 2px;
    }

    h2 {
        font-size: 2rem;
        margin-bottom: 10px;
        color: #e74c3c;
    }

    h3 {
        font-size: 1.5rem;
        margin-bottom: 10px;
    }

    /* Links */
    a {
        color: #2980b9;
        text-decoration: none;
        font-weight: bold;
        transition: color 0.2s ease;
    }

    a:hover {
        color: #e74c3c;
    }

    /* Lists */
    ul {
        list-style: none;
        padding-left: 0;
    }

    ul li {
        background: #ecf0f1;
        margin: 10px 0;
        padding: 10px;
        border-left: 5px solid #3498db;
        transition: background-color 0.3s ease;
    }

    ul li:hover {
        background: #bdc3c7;
    }

    /* Code Blocks */
    pre {
        background: #2c3e50;
        color: #ecf0f1;
        padding: 20px;
        border-radius: 5px;
        font-size: 1rem;
        overflow-x: auto;
    }

    code {
        background: #ecf0f1;
        padding: 2px 5px;
        border-radius: 3px;
        color: #e74c3c;
        font-family: 'Courier New', Courier, monospace;
    }

    /* Horizontal Rule */
    hr {
        border: none;
        border-top: 2px solid #3498db;
        margin: 30px 0;
    }

    /* Buttons */
    .btn {
        display: inline-block;
        background: #3498db;
        color: #fff;
        padding: 10px 20px;
        border-radius: 5px;
        text-transform: uppercase;
        font-weight: bold;
        transition: background-color 0.3s ease;
    }

    .btn:hover {
        background: #2980b9;
    }

    /* Footer */
    footer {
        text-align: center;
        padding: 20px;
        background-color: #34495e;
        color: #ecf0f1;
        margin-top: 50px;
        border-radius: 10px;
    }

    nav {
        background-color: #3498db;
        padding: 15px;
        text-align: center;
    }

    nav a {
        color: white;
        text-decoration: none;
        font-size: 1.2em;
        margin: 0 15px;
        transition: color 0.3s ease;
    }

    nav a:hover {
        color: #e74c3c;
    }

</style>
