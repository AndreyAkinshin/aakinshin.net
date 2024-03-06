---
title: Reinstalling TinyTeX
tags:
- TeX
---

If something goes wrong with [TinyTeX](https://yihui.org/tinytex/),
  the following debugging guide is recommended:
  https://yihui.org/tinytex/r/#debugging
Essentially, it recommends the following:

```r
update.packages(ask = FALSE, checkBuilt = TRUE)
tinytex::tlmgr_update()
tinytex::reinstall_tinytex()
```

Sometimes it works, but the real pain emerges when it comes to missing packages.
As an ultimate solution to this problem, one may consider installing the full TeX bundle.
The actual list of bundles is available here: https://github.com/rstudio/tinytex-releases#releases

The `TinyTeX-2` is the biggest one, it contains the `scheme-full` scheme of TeX Live.
Therefore, the command

```r
tinytex::install_tinytex(bundle = "TinyTeX-2")
```

installs 1.4..1.8GB of packages and solves most of the problems.