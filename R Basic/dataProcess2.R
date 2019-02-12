#R에 내장된 데이터 셋 
library(help = datasets)

head(iris)
str(iris)

#apply
d <- matrix(1:9, ncol=3)
d

apply(d, 1, sum) # 2번째 param: 1->행, 2->열 
apply(d, 2, sum)

apply(iris[, 1:4], 1, sum)


########## doBy package
# install.packages("doBy")
# https://cran.r-project.org/src/contrib/Archive/ 에서 버전에 맞는 package install
### 다운한 packages를 R설치폴더 밑의 library폴더에 적용 
install.packages("doBy")

library(doBy)
?orderBy
head(orderBy(~ Sepal.Width, iris))


# sample
sample(1:10, 5)
sample(1:10, 5, replace=F)          #비복원 추출
sample(1:10, 5, replace=T)          #복원 추출 

head(iris[sample(nrow(iris), nrow(iris)),])

# sampleBy    (test용 training용 데이터 추출)
sam = sampleBy(~Species, frac=0.3, data = iris)    # 종별로 30%로 추출 
str(sam)


# split(), subset()
attach(iris)                 #dettach-> 제거 
split(iris, iris$Species)

# 조건을 만족하는 부분만 반환 
subset(iris, Species == "setosa")   
subset(iris, Species == "setosa" & Sepal.Length > 5.0)

x <- data.frame(name = c("a", "b", "c"), math = c(1, 2, 3))
y <- data.frame(name = c("c", "b", "a"), english = c(4, 5, 6))
merge(x, y)

# 그룹별 연산 
aggregate(Sepal.Width ~ Species, iris, mean)


############## MySql 연동
# CREATE DATABASE rtest()
# CREATE TABLE tblScore(
#   id    int not null,
#   class int(2) not null,
#   mat   int(3) default 0,
#   eng   int(3) default 0,
#   sci   int(3) default 0
#)
# insert into tblscore values(5, 5, 80,80, 70);


install.packages(("rJava"))
install.packages("DBI")
install.packages("RMySQL")


#update.packages()

library(RMySQL)

conn <- dbConnect(MySQL(), dbname = "rtest", user = "root", password = "1111", host = "127.0.0.1")
conn

print(dbListTables(conn))
result <- dbGetQuery(conn, "select count(*) from tblscore")

#table field list
dbListFields(conn,"tblscore")

# dml의 경우
dbSendQuery(conn, "delete from tblscore")

data <- read.table("data/score.txt", header=T, sep = ",")
data

dbSendQuery(conn, "drop table tblscore")
dbWriteTable(conn, "tblScore", data, overwrite=F, row.names=F)

df <- dbGetQuery(conn, "select * from tblscore")
df

dbDisconnect(conn)
detach("package:RMySQL", unload = T)

#install sqldf: sql을 이용해서 data조작 
#install.packages("sqldf")
library(sqldf)
sqldf("select * from iris limit 5")
sqldf("select * from iris order by Species limit 10")
sqldf('select sum("Sepal.Length") from iris')
sqldf("select distinct Species from iris")
sqldf("select Species, count(*) from iris group by Species")

library(sqldf)
library(MASS)
str(Cars93)
(type_mpg_mean <- sqldf('select "Type", avg("MPG.city") as ave_city, avg("MPG.highway") as avg_highway from Cars93 group by Type'))

################## data.table
# install.packages("data.table")
library(data.table)

it <- iris
class(it)

it <- as.data.table(iris)
class(it)

tables()

it[1,]

# Species가 "setosa"인 행만 출력
it[it$Species == "setosa", ]

# sepal.Length의 평균값 
it[, mean(Sepal.Length)]


# sepal.Length의 평균값 species별로 계산 
it[, mean(Sepal.Length), by = "Species"]

(x <- data.table(x = c(1, 2, 3), y = c("a", "b", "c")))


# data.frame과 data.table의 성능 비교
df <- data.frame( x = runif(2600000), y = rep(LETTERS, each = 100000))
str(df)
head(df)
system.time(x <- df[df$y == "c", ])

dt <- as.data.table(df)
setkey(dt, y)                       # y를 기준으로 함.
system.time(x <- dt[J("c"), ])     #J(): 특정 컬럼 값을 get 


################## 유닛 테스팅과 디버깅
# install.packages("testthat")
library(testthat)

a <- 1:3
b <- 1:3
expect_equal(a, b)
expect_equivalent(a, b)

names(a) <- c("a", "b", "c")
expect_equal(a, b)
expect_equivalent(a, b)
 

# 피보나치 수열을 이용한 단위테스트
# fib <- function(n){
#   if(n ==0 || n==1)
#     return (1)
#   
#   if(n>1){
#     return(fib(n-1) + fib(n-2))
#   }
# }

# rm(fib) # 메모리상 올라가 있는 정보 삭제

source("myFunc/fibonacci.R")
# expect_equal(1, fib(0))
# expect_equal(1, fib(1))
# expect_equal(2, fib(2))
# expect_equal(3, fib(3))
# expect_equal(5, fib(4))

source("tests/run_fibonacci.R")

sum_to_ten <- function(){
  sum <- 0
  
  for(i in 1:10){
    sum <- sum + i
    
    if( i >= 5){
      browser()
    }
  }
  
  return (sum)
}

(result = sum_to_ten())
