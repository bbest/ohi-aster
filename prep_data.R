# code borrowed from https://github.com/bbest/rmarkdown-example/blob/master/test.Rmd

# extract data ----

suppressPackageStartupMessages({
  require(dplyr)
  require(knitr)
  require(RColorBrewer)
  suppressWarnings(require(ohicore)) # devtools::install_github('ohi-science/ohicore')
})

refresh_data = F

# get data
csv_d = 'data/scores.csv'
if (!file.exists(csv_d) | refresh_data){
  dir.create('data', showWarnings=F)
  
  # get scores
  url_scores = 'https://raw.githubusercontent.com/OHI-Science/ohi-global/master/eez2014/scores.csv'
  tmp_scores = tempfile(fileext='.csv')
  download.file(url_scores, tmp_scores, method='curl')
  scores = read.csv(tmp_scores)
  
  # get labels
  url_labels = 'https://raw.githubusercontent.com/OHI-Science/ohi-global/master/eez2014/layers/rgn_labels.csv'
  tmp_labels = tempfile(fileext='.csv')
  download.file(url_labels, tmp_labels, method='curl')
  labels = read.csv(tmp_labels)
  
  # explore
  # head(scores)
  # head(labels)
  # select(scores, goal, dimension) %>% table()
  
  # merge
  d = scores %>%
    inner_join(
      labels %>%
        select(
          region_id    = rgn_id, 
          region_label = label) %>%
        rbind(data.frame(
          region_id    = 0, 
          region_label = 'GLOBAL')),
      by='region_id') %>%
    filter(dimension=='score')
  
  # write and cleanup
  write.csv(d, csv_d, row.names=F, na='')
  unlink(c(tmp_scores, tmp_labels))
}
d = read.csv(csv_d) %>%
  arrange(desc(score))

# get goals
csv_g = 'data/goals.csv'
if (!file.exists(csv_g) | refresh_data){
  url_goals = 'https://raw.githubusercontent.com/OHI-Science/ohi-global/master/eez2014/conf/goals.csv'
  tmp_goals = tempfile(fileext='.csv')
  download.file(url_goals, tmp_goals, method='curl')
  g = read.csv(tmp_goals)
  g = g %>%
    filter(!goal %in% g$parent) %>%
    select(goal, weight, order_color, name_flower)
  write.csv(g, csv_g, row.names=F, na='')
  unlink(c(tmp_goals))
}
g = read.csv(csv_g) %>%
  arrange(order_color)


# plot static flower plot ----

# combine goals with scores
x = g %>%
  inner_join(
    d %>%
      filter(region_label=='GLOBAL' & goal!='Index') %>%
      select(goal, score),
    by='goal') %>%
  arrange(order_color)

# plot
png('flower.png', width=800, height=800, res=150)
PlotFlower(
  main       = '',
  lengths    = x$score,
  widths     = x$weight,
  fill.col   = colorRampPalette(brewer.pal(10, 'Spectral'), space='Lab')(nrow(x)),
  labels     = paste(gsub('\\\\n','\\\n', x$name_flower), round(x$score), sep='\n'),
  center     = round(d %>% filter(region_label=='GLOBAL' & goal=='Index') %>% select(score)),
  disk       = 0.4, 
  max.length = 100, cex=2, label.cex=0.5, label.offset=0.13)
dev.off()
system('open flower.png')

# aggregate data into sin