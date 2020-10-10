\ProvidesClass{btrpstr}[2020/10/09 v0.1 btrpstr class]
\NeedsTeXFormat{LaTeX2e}[1995/06/01]
\typeout{minimalistic BetterPoster for LaTeX}
\LoadClass{article}

\RequirePackage{calc}
\RequirePackage{scrextend}
\RequirePackage{pgfopts}
\RequirePackage{ifthen}
\RequirePackage{geometry}

\RequirePackage{tikz}
\usetikzlibrary{calc,fit}

% A small TODO list:
% - parametrize \thispagestyle{empty} ?
% - normalize all names that now start randomly with p@whatever?
% - bottom-aligned boxes? lines around boxes? (requires drawing the box path
%   separately, like in baposter)
% - `above` option instead of `bottom`. Generally, a more flexible way to
%   specify the posterbox/headerbox position would be cool.

\pgfqkeys{/btrpstr}{
  geometry/.code=\geometry{#1},
  a0v/.code=\geometry{a0paper,portrait},
  a0h/.code=\geometry{a0paper,landscape},
  a1v/.code=\geometry{a1paper,portrait},
  a1h/.code=\geometry{a1paper,landscape},
  a2v/.code=\geometry{a2paper,portrait},
  a2h/.code=\geometry{a2paper,landscape},
  a3v/.code=\geometry{a3paper,portrait},
  a3h/.code=\geometry{a3paper,landscape},
  a4v/.code=\geometry{a4paper,portrait},
  a4h/.code=\geometry{a4paper,landscape}}
\ProcessPgfOptions{/btrpstr}

\pgfdeclarelayer{posterbg}
\pgfsetlayers{posterbg,main}

\pgfqkeys{/poster}{
  fontsizes/.value required,
  fontsizes/.code=\changefontsizes{#1}}
\newenvironment{poster}[1][]{%
  \pgfqkeys{/poster}{#1}%
  \thispagestyle{empty}
  \begin{tikzpicture}[remember picture, overlay]
  \pgfnodealias{poster}{current page}
}{%
  \end{tikzpicture}%
  \clearpage%
}

\newlength\p@stertmpX
\newlength\p@stertmpY
\def\p@stergettmpX#1{\path #1;\pgfgetlastxy{\p@stertmpX}{\p@stertmpY}}
\newenvironment{colminipage}[2]{%
\p@stergettmpX{($(column #1 span) - (column #1 start)$)}%
\begin{minipage}[t]{\p@stertmpX-(#2)}\bgroup}{\egroup\end{minipage}}

\newif\ifp@cusewidth
\pgfqkeys{/postercol}{
  start/.code={
    \edef\p@stertmp{(column \p@stercolname\space start)}
    \expandafter\coordinate\p@stertmp at #1;},
  span/.code={
    \edef\p@stertmp{(column \p@stercolname\space span)}
    \expandafter\coordinate\p@stertmp at #1;},
  width/.code=\pgfqkeys{/postercol}{usewidth,thewidth={#1}},
  usewidth/.is if=p@cusewidth,
  thewidth/.store in=\p@cwidth}
\newcommand{\newpostercol}[2]{
  \def\p@stercolname{#1}
  \pgfqkeys{/postercol}{usewidth=false}
  \pgfqkeys{/postercol}{#2}
  \ifp@cusewidth
    \edef\p@stertmp{(column \p@stercolname\space span) at ([xshift=\p@cwidth] column \p@stercolname\space start)}
    \expandafter\coordinate\p@stertmp;
  \fi
}

\newif\ifp@splitnew
\newlength\p@splitw
\newlength\p@spliti
\newlength\p@splitc
\newlength\p@splito
\pgfqkeys{/splitcol}{
  make parent/.code=\pgfqkeys{/splitcol}{newcolopts/.style={#1},donewcol},
  donewcol/.is if=p@splitnew,
  n/.store in=\p@splitn,
  left sep/.store in=\p@splitleft,
  right sep/.store in=\p@splitright,
  side sep/.code=\pgfqkeys{/splitcol}{left sep=#1,right sep=#1},
  col sep/.store in=\p@splitsep}
\newcommand{\splitpostercol}[2]{
  \pgfqkeys{/splitcol}{
    donewcol=false,
    n=2,
    side sep=0pt,
    col sep=1em}
  \def\p@splitname{#1}
  \pgfqkeys{/splitcol}{#2}
  \ifp@splitnew
    \typeout{Really creating the new column #1}
    \newpostercol{#1}{/splitcol/newcolopts}
  \fi
  \p@stergettmpX{($(column #1 span) - (column #1 start)$)}\setlength\p@splitw\p@stertmpX
  \typeout{The length: \the\p@splitw}
  \setlength\p@spliti{(\p@splitw - \p@splitleft - \p@splitright + \p@splitsep) / \p@splitn}
  \typeout{col increase: \the\p@spliti}
  \setlength\p@splitc{(\p@splitw - \p@splitleft - \p@splitright - \p@splitsep*(\p@splitn-1)) / \p@splitn}
  \typeout{col width: \the\p@splitc}
  \foreach \col in {1,...,\p@splitn} {
    \typeout{New poster col: \p@splitname\col}
    \setlength\p@splito{\p@splitleft + \p@spliti*(\col-1)}
    \typeout{offset from left: \the\p@splito}
    \newpostercol
      {\p@splitname\col}
      {start={([xshift=\p@splito] column \p@splitname\space start)},
       width=\the\p@splitc}
  };
}

\newenvironment{background}{\begin{pgfonlayer}{posterbg}}{\end{pgfonlayer}}
\newcommand{\posterbackground}[1]{%
\begin{background}
\path[#1] (current page.north west) rectangle (current page.south east);
\end{background}}
\newcommand{\posterboxbackground}[3]{%
\begin{background}
\node[fit=#2,#3] (#1) {};
\end{background}}

\pgfqkeys{/posterbox}{
  col/.store in=\p@boxcol,
  below/.store in=\p@boxbelow,
  style/.code=\pgfkeys{/posterbox/boxstyle/.style={#1}},
  font/.store in=\p@boxfont,
  extra padding/.store in=\p@boxpadding,
  sep/.value required,
  sep/.store in=\p@boxsep,
  offset/.store in=\p@boxoffset}
\newbox\p@sterbox
\newenvironment{posterbox}[2]{
  \pgfqkeys{/posterbox}{ %defaults
    col=,
    below=,
    style=,
    font=,
    extra padding=0pt,
    sep=.5em,
    offset=0pt}
  \def\p@boxname{#1}
  \pgfqkeys{/posterbox}{#2}
  \ifthenelse{\equal{\p@boxcol}{}}{
    \@latex@error{posterbox argument col undefined!}
  }{}
  \ifthenelse{\equal{\p@boxbelow}{}}{
    \def\p@boxbelowX{column \p@boxcol\space start}
  }{
    \def\p@boxbelowX{\p@boxbelow.south}
  }
  \edef\p@sterboxpars{[anchor=north west,/posterbox/boxstyle,inner sep=\p@boxsep] (\p@boxname)
    at ([yshift=-\p@boxoffset] column \p@boxcol\space start |- \p@boxbelowX)%
    }
  \setbox\p@sterbox=\hbox\bgroup%
    \begin{colminipage}{\p@boxcol}{\p@boxsep*2+\p@boxpadding}%
    \begin{pgfinterruptpicture}%
    \p@boxfont%
}{%
    \ifhmode\par\fi%
    \end{pgfinterruptpicture}%
    \end{colminipage}%
  \egroup
  \expandafter\node\p@sterboxpars
    {\usebox{\p@sterbox}};
}

\def\p@hdrname{header}
\def\p@bodyname{body}
\pgfqkeys{/hdrbox}{
  col/.store in=\p@hboxcol,
  below/.store in=\p@hboxbelow,
  header style/.code=\pgfkeys{/hdrbox/xhdrstyle/.style={#1}},
  header/.store in=\p@hboxhdr,
  header font/.store in=\p@hboxhdrfont,
  body style/.code=\pgfkeys{/hdrbox/xbodystyle/.style={#1}},
  font/.store in=\p@hboxfont,
  extra padding/.store in=\p@hboxpadding,
  sep/.store in=\p@hboxsep,
  offset/.store in=\p@hboxoffset,
  body offset/.store in=\p@hboxbodyoffset}
\newenvironment{headerbox}[2]{
  \pgfqkeys{/hdrbox}{
    col=,
    below=,
    header style=,
    header=,
    header font=\bfseries,
    body style=,
    font=,
    extra padding=0pt,
    sep=.5em,
    offset=0pt,
    body offset=0pt}
  \def\p@hboxname{#1}
  \pgfqkeys{/hdrbox}{#2}
  \begin{posterbox}{\p@hboxname\p@hdrname}
    {col=\p@hboxcol, below=\p@hboxbelow,
     extra padding=\p@hboxpadding, sep=\p@hboxsep, offset=\p@hboxoffset,
     font=\p@hboxhdrfont, style=/hdrbox/xhdrstyle}\p@hboxhdr\end{posterbox}
  \begin{posterbox}{\p@hboxname\p@bodyname}
    {col=\p@hboxcol, below=\p@hboxname\p@hdrname,
     extra padding=\p@hboxpadding, sep=\p@hboxsep, offset=\p@hboxbodyoffset,
     font=\p@hboxfont, style=/hdrbox/xbodystyle}}
{\end{posterbox}
  \node[inner sep=0pt,fit=(\p@hboxname\p@hdrname)(\p@hboxname\p@bodyname)]
    (\p@hboxname) {};}
