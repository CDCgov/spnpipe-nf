#!/usr/bin/env Rscript

## Function Build_PBP_AA_table
Build_PBP_AA_table<- function(datafolder, temp_path)
{

  #Four Files required in the datafolder wiith exact names as following: 
  #file1: Ref_PBP_3.faa: containing the 3 reference PBP AA sequences
  #file2: Sample_PBP1A_AA.faa:   containing PBP1A AA sequences from ALL samples 
  #file3: Sample_PBP2B_AA.faa:   containing PBP2B AA sequences from ALL samples 
  #file4: Sample_PBP2X_AA.faa:   containing PBP2X AA sequences from ALL samples 

  setwd(datafolder)
  libpath=gsub(" ", "", paste(temp_path, "/Rlib"))
  x2=c(libpath, "/usr/lib64/R/library", "/usr/share/R/library")
  .libPaths(x2)

  library("Biostrings")
  
  # Refactored to take in relative path to clustalo binary located in repo
  clean_clustal <- normalizePath(temp_path)
  print(clean_clustal)
  cmd1="clustalo"    
  print(cmd1)

  # Get path to reference from relative path while removing whitespaces from paste
  refPBP3=gsub(" ", "", paste(temp_path, "/PBP_AA_to_MIC_newDB/Ref_PBP_3.faa"))
  seq1=readAAStringSet(refPBP3, format="fasta")
  sampleID="TIGR4-AE005672.3"

  s1A=unlist(strsplit(as.character(seq1[[2]]), split=""))
  x1A=paste("PBP1A_", s1A, (370+(1:length(s1A))), sep="")
    #PBP1A TPD starts at SP_0369 AA 371 and ends at AA647

  s2B=unlist(strsplit(as.character(seq1[[3]]), split=""))
  x2B=paste("PBP2B_", s2B, (378+(1:length(s2B))), sep="")
    #PBP2B TPD starts at AA 379 and ends at AA 656

  s2X=unlist(strsplit(as.character(seq1[[1]]), split=""))
  x2X=paste("PBP2X_", s2X, (228+(1:length(s2X))), sep="")
    #PBP1A TPD starts at AA 229 and ends at AA 587

  PBP1A_NF="0"
  PBP2B_NF="0"
  PBP2X_NF="0"

  r1=c(sampleID, PBP1A_NF, PBP2B_NF, PBP2X_NF, s1A,s2B, s2X)
  names(r1)=c("sampleID", "PBP1A_NF", "PBP2B_NF", "PBP2X_NF", x1A,x2B, x2X)
  write.csv(t(r1), file="Ref_PBP_AA_table.csv", row.names=F)
  
  seqREF=readAAStringSet(refPBP3, format="fasta")
    mREF=read.csv("Ref_PBP_AA_table.csv", colClasses="character")
  seq1A=readAAStringSet("Sample_PBP1A_AA.faa", format="fasta")
  seq2B=readAAStringSet("Sample_PBP2B_AA.faa", format="fasta")
  seq2X=readAAStringSet("Sample_PBP2X_AA.faa", format="fasta")
  ID1=unique(c(names(seq1A), names(seq2B), names(seq2X)))
  
  mSAM=mREF
  for (j1 in ID1)
  {
    NF1A=1
    if (j1 %in% names(seq1A))
    { NF1A=0
      x1=as.character(seq1A[j1][[1]])
      x2=as.character(seqREF["PBP1A_SP0369_AA371-647"][[1]])
      if (nchar(x1) < nchar(x2)/2) {NF1A=1}
        # sample seq lentgh less than half of REF length: consider as NF 
      if (nchar(gsub("-","",x1)) < nchar(x2)/2) {NF1A=1}
        # sample contians "-" more than half of REF length: consider as NF 
    }

    if (NF1A==0)
    {
      writeXStringSet(seqREF["PBP1A_SP0369_AA371-647"], file="tempSAM1A.faa")
      writeXStringSet(seq1A[j1], file="tempSAM1A.faa", , append=T  )
      
      #system("chown -R $USER:$USER ")
      absoluteDir <- getwd()
      print("ABOUT to run clustalo")
      cmd2 <- paste0(" -i ", absoluteDir, "/tempSAM1A.faa -o ", absoluteDir, "/tempSAM1A.faa.aln --wrap=3000 --force --output-order=input-order")
      cmd3=paste(cmd1, cmd2, sep="")
      #cmd3=paste(cmd0, cmd1, cmd2, sep="")
      print(cmd3)
      test_in = paste0(absoluteDir, "/tempSAM1A.faa")
      test_out = paste0(absoluteDir, "/tempSAM1A.faa.aln")
      s2_args = c('-i', test_in, '-o', test_out, '--wrap=3000', '--force', '--output-order=input-order')
      
      system2(cmd1, s2_args, stdout = TRUE, stderr = TRUE)
      print("RAN clustalo")

      seqTEMP2=readAAStringSet("tempSAM1A.faa.aln", format="fasta")
      x1=as.character(seqTEMP2["PBP1A_SP0369_AA371-647"][[1]])
      x2=as.character(seqTEMP2[j1][[1]])
      x3=unlist(strsplit(x1, split=""))
      x4=unlist(strsplit(x2, split=""))
      m1=cbind(x3,x4)
      n1=dim(m1)[1]
      n2=0
      x5=F
      for (j2 in 1:n1)
      {      
        if (m1[j2, 1]=="-" & x5==F) {n2=n2+1} else {x5=T}
      }
      if (n2>0) {m1=m1[-(1:n2),]}
        # To remove leading "-" before REF
    
      n1=dim(m1)[1]
      n2=n1+1
      x5=F
      for (j2 in n1:1)
      {      
        if (m1[j2, 1]=="-" & x5==F) {n2=n2-1} else {x5=T}
      }
      if (n2<(n1+1)) {m1=m1[-(n1:n2),]}
        # To remove trailing "-" after REF

      n1=dim(m1)[1]
      n2=0
      x5=F
      x6=(m1[, 1]!="-")
      S1A=NULL
      for (j2 in 1:(n1-1))
      {
        if (x6[j2])
        {      
           if (x6[j2] & x6[j2+1]) 
           {tempSAA=m1[j2,2]} else 
           {
             tempSAA=paste(m1[j2:(j2+which(x6[(j2+1):n1])[1]-1),2], collapse="")
           }
             S1A=c(S1A, tempSAA)
        } 
      }
         S1A=c(S1A, m1[n1,2])
         S1Akeep=S1A
    } else
    {
     S1Akeep=rep(NA, width(seqREF["PBP1A_SP0369_AA371-647"])[1])    
    }
##
    NF2B=1
    if (j1 %in% names(seq2B))
    { NF2B=0
      x1=as.character(seq2B[j1][[1]])
      x2=as.character(seqREF["PBP2B_SP0369_AA379-656"][[1]])
      if (nchar(x1) < nchar(x2)/2) {NF2B=1}
        # sample seq lentgh less than half of REF length: consider as NF 
      if (nchar(gsub("-","",x1)) < nchar(x2)/2) {NF2B=1}
        # sample contians "-" more than half of REF length: consider as NF 
    }

    if (NF2B==0)
    {
      writeXStringSet(seqREF["PBP2B_SP0369_AA379-656"], file="tempSAM1A.faa")
      writeXStringSet(seq2B[j1], file="tempSAM1A.faa", , append=T  )
    
      cmd2=" -i tempSAM1A.faa -o tempSAM1A.faa.aln --wrap=3000 --force  --output-order=input-order"
      cmd3=paste(cmd1, cmd2, sep="")
      system(cmd3)

      seqTEMP2=readAAStringSet("tempSAM1A.faa.aln", format="fasta")
      x1=as.character(seqTEMP2["PBP2B_SP0369_AA379-656"][[1]])
      x2=as.character(seqTEMP2[j1][[1]])
      x3=unlist(strsplit(x1, split=""))
      x4=unlist(strsplit(x2, split=""))
      m1=cbind(x3,x4)
      n1=dim(m1)[1]
      n2=0
      x5=F
      for (j2 in 1:n1)
      {      
        if (m1[j2, 1]=="-" & x5==F) {n2=n2+1} else {x5=T}
      }
      if (n2>0) {m1=m1[-(1:n2),]}
      # To remove leading "-" before REF
    
      n1=dim(m1)[1]
      n2=n1+1
      x5=F
      for (j2 in n1:1)
      {      
        if (m1[j2, 1]=="-" & x5==F) {n2=n2-1} else {x5=T}
      }
      if (n2<(n1+1)) {m1=m1[-(n1:n2),]}
        # To remove trailing "-" after REF

      n1=dim(m1)[1]
      n2=0
      x5=F
      x6=(m1[, 1]!="-")
      S1A=NULL
      for (j2 in 1:(n1-1))
      {
        if (x6[j2])
        {      
          if (x6[j2] & x6[j2+1]) 
          {  
            tempSAA=m1[j2,2]
          } else 
          {
            tempSAA=paste(m1[j2:(j2+which(x6[(j2+1):n1])[1]-1),2], collapse="")}
            S1A=c(S1A, tempSAA)
           }
       } 
       S1A=c(S1A, m1[n1,2])
       S2B=S1A
    } else
    {
        S2B=rep(NA, width(seqREF["PBP2B_SP0369_AA379-656"])[1])    
    }

    NF2X=1
    if (j1 %in% names(seq2X))
    { NF2X=0
      x1=as.character(seq2X[j1][[1]])
      x2=as.character(seqREF["PBP2X_SP0336_AA229-587"][[1]])
      if (nchar(x1) < nchar(x2)/2) {NF2X=1}
        # sample seq lentgh less than half of REF length: consider as NF 
      if (nchar(gsub("-","",x1)) < nchar(x2)/2) {NF2X=1}
        # sample contians "-" more than half of REF length: consider as NF 
    }

    if (NF2X==0)
    {
      writeXStringSet(seqREF["PBP2X_SP0336_AA229-587"], file="tempSAM1A.faa")
      writeXStringSet(seq2X[j1], file="tempSAM1A.faa", , append=T  )
    
      cmd2=" -i tempSAM1A.faa -o tempSAM1A.faa.aln --wrap=3000 --force  --output-order=input-order"
      cmd3=paste(cmd1, cmd2, sep="")
      #cmd3=paste(cmd0, cmd1, cmd2, sep="")
      system(cmd3)

      seqTEMP2=readAAStringSet("tempSAM1A.faa.aln", format="fasta")
      x1=as.character(seqTEMP2["PBP2X_SP0336_AA229-587"][[1]])
      x2=as.character(seqTEMP2[j1][[1]])
      x3=unlist(strsplit(x1, split=""))
      x4=unlist(strsplit(x2, split=""))
      m1=cbind(x3,x4)
      n1=dim(m1)[1]
      n2=0
      x5=F
      for (j2 in 1:n1)
      {      
        if (m1[j2, 1]=="-" & x5==F) {n2=n2+1} else {x5=T}
      }
      if (n2>0) {m1=m1[-(1:n2),]}
        # To remove leading "-" before REF
    
      n1=dim(m1)[1]
      n2=n1+1
      x5=F
      for (j2 in n1:1)
      {      
        if (m1[j2, 1]=="-" & x5==F) {n2=n2-1} else {x5=T}
      }
      if (n2<(n1+1)) {m1=m1[-(n1:n2),]}
        # To remove trailing "-" after REF

      n1=dim(m1)[1]
      n2=0
      x5=F
      x6=(m1[, 1]!="-")
      S1A=NULL
      for (j2 in 1:(n1-1))
      {
        if (x6[j2])
        {      
          if (x6[j2] & x6[j2+1]) 
          {  
            tempSAA=m1[j2,2]
          } else 
          {
            tempSAA=paste(m1[j2:(j2+which(x6[(j2+1):n1])[1]-1),2], collapse="")}
            S1A=c(S1A, tempSAA)
         }
      } 
      S1A=c(S1A, m1[n1,2])
      S2X=S1A
    } else
    {
      S2X=rep(NA, width(seqREF["PBP2X_SP0336_AA229-587"])[1])    
    }
  tempROW=c(j1, NF1A, NF2B, NF2X, S1Akeep, S2B, S2X)
  if (length(tempROW)==sum(width(seqREF))+4)
    {
      mSAM=rbind(mSAM, tempROW)
    } else
    {
      cat(tempROW, file="failedSample.txt", sep=" ", append=T)
      cat("\n\n", file="failedSample.txt", append=T)
    }
    print(paste("finishing sample", j1) )

  } 

  write.csv(mSAM, file="Sample_PBP_AA_table.csv", row.names=F)
  
  mAA=read.csv("Sample_PBP_AA_table.csv", colClasses="character")
  n1=dim(mAA)
  x1=NULL
  x2=NULL
  for (j1 in 1:n1[1])
  {
    x1=c(x1, mAA[j1, 1])
    x2=c(x2, paste(mAA[j1, 2:n1[2]], collapse =""))
  }
  x3=unique(x2)
  x5=NULL
  for (j1 in x3)
  {
    x6=which(x2 == j1)[1]
    x5=rbind(x5, mAA[x6,])
  }
  write.csv(x5, file="Unique_PBP_AA_table.csv", row.names=F)
} 
args <- commandArgs(TRUE)
cwd = args[1]
t_path = args[2]

Build_PBP_AA_table(cwd, t_path)

## End of Function Build_PBP_AA_table