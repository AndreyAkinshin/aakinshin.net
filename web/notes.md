---
layout : default
title : Andrey Akinshin's blog
permalink: /notes/
paginate: 10
paginate_lang: en
paginate_type: note
paginate_link: "/notes/page/:page/"
---
@model Pretzel.Logic.Templating.Context.PageContext

<div class="blog-main">
@foreach (var post in Model.Paginator.Posts)
{
    var excerpt = (string)post.Bag["excerpt"];
    var commentsLink = @post.Url.Replace("index.html", "") + "#disqus_thread";
    <div class="blog-post">
        <h2 class="blog-post-title"><a href='@post.Url.Replace("index.html", "")'>@post.Title</a></h2>
        <span class="blog-post-meta">
          <b>Date:</b> @post.Date.ToString("MMMM dd, yyyy", new System.Globalization.CultureInfo("en-US")).
          <b>Tags:</b>
            @foreach(var tag in post.Tags)
            {
                <a href="/tags/@Pretzel.Logic.Extra.UrlAliasFilter.UrlAlias(tag)"><span class="badge badge-pill badge-info">@tag</span></a>
            }
        </span><br /><br />
        @Raw(excerpt)
        <a href='@post.Url.Replace("index.html", "")'>Read more</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="@commentsLink">Comments</a><br /><br />
        <hr />
    </div>
}
</div>

<nav>
  <ul class="pagination">
    @if (Model.Paginator.PreviousPageUrl != null)
    {
      <li class="page-item">
        <a class="page-link" href='@Model.Paginator.PreviousPageUrl.Replace("index.html", "")' aria-label="Previous">
          <span aria-hidden="true">&laquo;</span>
          <span class="sr-only">Previous</span>
        </a>
      </li>
    }
    @if (Model.Paginator.PreviousPageUrl == null)
    {
      <li class="page-item disabled">
        <a class="page-link" href="#" aria-label="Previous">
          <span aria-hidden="true">&laquo;</span>
          <span class="sr-only">Previous</span>
        </a>
      </li>
    }
    @for (int i = 1; i <= Model.Paginator.TotalPages; i++)
    {
      var link = i == 1 ? "/posts/" : "/posts/page/" + i.ToString() + "/";
      if (Model.Paginator.Page == i)
      {
        <li class="page-item active">
          <a class="page-link" href="@link">@i <span class="sr-only">(current)</span></a>
        </li>
      }
      if (Model.Paginator.Page != i)
      {
        <li class="page-item"><a class="page-link" href="@link">@i</a></li>
      }
    }
    @if (Model.Paginator.NextPageUrl != null)
    {
      <li class="page-item">
        <a class="page-link" href='@Model.Paginator.NextPageUrl.Replace("index.html", "")' aria-label="Next">
          <span aria-hidden="true">&raquo;</span>
          <span class="sr-only">Next</span>
        </a>
      </li>
    }
    @if (Model.Paginator.NextPageUrl == null)
    {
      <li class="page-item disabled">
        <a class="page-link" href="#" aria-label="Next">
          <span aria-hidden="true">&raquo;</span>
          <span class="sr-only">Next</span>
        </a>
      </li>
    }
  </ul>
</nav>

<hr />
<p>Subscribe: <a href="/rss.xml">RSS</a> <a href="/atom.xml">Atom</a></p>