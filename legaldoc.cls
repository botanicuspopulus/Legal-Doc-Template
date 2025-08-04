\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{legaldoc}[2025/02/07 Custom legal document class]

\newcommand*\PrintOath{}
\newcommand*\InsertAnnexure{}
\newcommand*\documenttitle

\newcommand{\DeclareAffidavitOption}[2]{
    \DeclareOption{#1}{
        \renewcommand{\documenttitle}{#2}
        \def\affidavit{}
    }
}

\newcommand{\DeclareTitleOption}[2]{
    \DeclareOption{#1}{
        \renewcommand{\documenttitle}{#2}
    }
}

\DeclareAffidavitOption{supp-affidavit}{SUPPORTING AFFIDAVIT}
\DeclareAffidavitOption{found-affidavit}{FOUNDING AFFIDAVIT}
\DeclareAffidavitOption{confirm-affidavit}{CONFIRMATORY AFFIDAVIT}
\DeclareAffidavitOption{affidavit}{AFFIDAVIT}
\DeclareTitleOption{plea}{PLEA}
\DeclareTitleOption{notice-defend}{NOTICE OF INTENT TO DEFEND}
\DeclareTitleOption{notice-motion}{NOTICE OF MOTION}
\DeclareTitleOption{notice-filing}{NOTICE OF FILING}
\DeclareTitleOption{notice-service}{NOTICE OF SERVICE}
\DeclareTitleOption{notice-withdrawal}{NOTICE OF WITHDRAWAL}
\DeclareTitleOption{heads}{HEADS OF ARGUMENT}

\ProcessOptions\relax
\LoadClass[a4paper,12pt]{article}

\ifx\affidavit\undefined
\else
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
\fi

\input{config/packages}
\input{config/formatting}

\endinput