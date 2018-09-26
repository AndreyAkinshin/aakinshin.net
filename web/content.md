---
layout : default
title : Andrey Akinshin's blog / Content
permalink: /content/
redirect_from:
- /en/blog/content/
- /blog/content/
---
@model Pretzel.Logic.Templating.Context.PageContext

<h2>Content</h2>
<div>
@foreach(var year in Model.Site.EnPosts.Select(p => p.Date.Year).Distinct().OrderByDescending(y => y))
{
    var posts = Model.Site.EnPosts.Where(p => p.Date.Year == year).OrderByDescending(p => p.Date).ToList();
    if (posts.Count() > 0)
    {
        <h3 id="@year">@year</h3>
        <ul>
        @foreach(var post in posts)
        {
            <li><a href='@post.Url.Replace("index.html", "")'>@post.Title</a> <i>(@post.Date.ToString("MMMM dd", new System.Globalization.CultureInfo("en-US")))</i></li>
        }
        </ul>
    }
}
</div>
<hr />

<div>
@foreach(var tag in Model.Site.Tags.OrderByDescending(c => c.EnPosts.Count()))
{
    var posts = tag.EnPosts.Distinct().ToList();
    if (posts.Count() > 0)
    {
        <h3 id="@Pretzel.Logic.Extra.UrlAliasFilter.UrlAlias(tag.Name)">@tag.Name</h3>
        <ul>
        @foreach(var post in posts)
        {
            <li><a href='@post.Url.Replace("index.html", "")'>@post.Title</a> <i>(@post.Date.ToString("MMMM dd, yyyy", new System.Globalization.CultureInfo("en-US")))</i></li>
        }
        </ul>
    }
}
</div>
<hr />

<p style="font-size:150%"><a href="/ru/blog/content/">More posts in Russian</a></p>
<p>Subscribe: <a href="/en/rss.xml">RSS</a> <a href="/en/atom.xml">Atom</a></p>