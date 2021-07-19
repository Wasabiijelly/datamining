#############
##2021-07-12
##hyeyoon
#############

setRepositories(ind = 1:8)
library(stringr)
library(parallel)
library(doParallel)
library(foreach)

setwd("/disk3/bihy")
PATH_INPUT <- "/disk3/bihy/indexResult/" 
PATH_OUTPUT <- "/disk3/bihy/outputMapping2/"
PATH_FASTQ <- "/disk3/bipsw/" 
speciesName <- as.list(list.files("/disk3/bihy/indexResult"))
fastqName <- list.files(PATH_FASTQ,pattern="\\.gz")
SPECIES_NUM = 10

numCores <- 20
cl <- makeCluster(numCores)
registerDoParallel(cl)


#Check
#ars = (commandArgs(TRUE))

for(j in 1:(length(fastqName)/2)) {
  
  command <- "STAR --genomeDir indices/genome --readFilesIn readsortmerna-trimmomatic_1.fq.gz readsortmerna-trimmomatic_2.fq.gz --runThreadN 2 --readFilesCommand zcat --outFileNamePrefix results/read-sortmerna-trimmomatic-STAR"

  
  inputForward <- str_c(PATH_FASTQ,fastqName[2*j-1])
  inputReverse <- str_c(PATH_FASTQ,fastqName[2*j])
  
  #print(inputForward)
  #print(inputReverse)
  command <- str_replace(command,"readsortmerna-trimmomatic_1.fq.gz",inputForward)
  command <- str_replace(command,"readsortmerna-trimmomatic_2.fq.gz",inputReverse)
  
  result <- c()
  
  for(i in 1:SPECIES_NUM)  {
    newCommand <- command
    fileInput<- paste0(PATH_INPUT, speciesName[[i]])
    fileOutput <- paste0(PATH_OUTPUT, speciesName[[i]])
    newCommand <-str_replace(newCommand,"indices/genome", fileInput)
    newCommand <-str_replace(newCommand,"results/read-sortmerna-trimmomatic-STAR", fileOutput)
    
    result <- append(result, newCommand)
    #print(result)
  }
  
  foreach(i = 1:SPECIES_NUM) %dopar% {
    system(result[i])
   # print("command")
  }
  
}


############################################################################################
finalFile <- (list.files(PATH_OUTPUT))
finalFile <- finalFile[grep("final", finalFile)]
finalFile <- str_c(PATH_OUTPUT,finalFile)

mapRate <- c()
for(i in 1:SPECIES_NUM){
  temp <- (read.delim(finalFile[i], header = FALSE))$V2[9] %>% 
    str_remove("%")
  
  mapRate <- append(mapRate, as.numeric(temp))
}

max_index <- which.max(mapRate)

print("*************************************************************************")
sprintf("                            %s                                ", speciesName[max_index])
print("*************************************************************************")





