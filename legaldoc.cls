\NeedsTeXFormat{LaTeX2e}
\usepackage{xstring}
\usepackage{etoolbox}

\ProvidesClass{legaldoc}[2025/02/07 Custom legal document class]

\newcommand*\PrintOath{}
\newcommand*\InsertAnnexure{}
\newcommand*\documenttitle{}

\newbool{enableAnnexures}
\setbool{enableAnnexures}{false}

\newbool{insertOath}
\setbool{insertOath}{false}

\newcommand{\setdocumenttitle}[1]{
  \renewcommand{\documenttitle}{\uppercase{#1}}
}

\DeclareOption{enableannexures}{\setbool{enableAnnexures}{true}}
\DeclareOption{insertoath}{\setbool{insertOath}{true}}

\ProcessOptions\relax
\LoadClass[a4paper,12pt]{article}

\ifbool{enableAnnexures}{
  \newcommand*\pdfpagesheaderright{}
  \newcounter{annexureNumber}

  \newcommand{\setlayout}[1]{
      \thispagestyle{pdfpages}%
      \gdef\pdfpagesheaderright{#1}%
  }

  \renewcommand{\InsertAnnexure}[1]{
      \refstepcounter{annexureNumber}

      \section*{Annexure \theannexureNumber}\label{annexure:\theannexureNumber}
      \includepdf[pages=-,pagecommand=\setlayout{\theannexureNumber},height=\textheight,width=\textwidth,keepaspectratio]{#1}
  }

  \newcommand{\annexure}[1]{Annexure \ref{annexure:#1}}
}{}

\input{config/packages}
\input{config/formatting}

\endinput
