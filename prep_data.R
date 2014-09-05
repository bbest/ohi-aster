# code borrowed from https://github.com/bbest/rmarkdown-example/blob/master/test.Rmd

# extract data ----

suppressPackageStartupMessages({
  require(dplyr)
  require(knitr)
  require(RColorBrewer)
  require(stringr)
  suppressWarnings(require(ohicore)) # devtools::install_github('ohi-science/ohicore')
})

# variables
yr = 2014
url_scores = sprintf('https://raw.githubusercontent.com/OHI-Science/ohi-global/master/eez%d/scores.csv', yr)
url_labels = sprintf('https://raw.githubusercontent.com/OHI-Science/ohi-global/master/eez%d/layers/rgn_labels.csv', yr)
url_goals  = sprintf('https://raw.githubusercontent.com/OHI-Science/ohi-global/master/eez%d/conf/goals.csv', yr)
csv_d = 'data/scores.csv'
csv_g = 'data/goals.csv'
csv_p = 'data/aster_data.csv'
flower_png = 'flower.png'
refresh_data = F

dir.create('data', showWarnings=F)

# get data
if (!file.exists(csv_d) | refresh_data){
  
  # get scores
  tmp_scores = tempfile(fileext='.csv')
  download.file(url_scores, tmp_scores, method='curl')
  scores = read.csv(tmp_scores)
  
  # get labels
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
if (!file.exists(csv_g) | refresh_data){
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
png(flower_png, width=800, height=800, res=150)
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
system(sprintf('open %s', flower_png))

# aggregate data into single csv for d3 rendering
p = data.frame(
  id     = x$goal,
  order  = x$order_color,
  score  = round(x$score),
  weight = x$weight,
  color  = colorRampPalette(brewer.pal(10, 'Spectral'), space='Lab')(nrow(x)),
  label  = str_trim(gsub('\\\\n',' ', x$name_flower))
)
write.csv(p, csv_p, row.names=F)
cat(paste('Extracted weighted average score :', round(d %>% filter(region_label=='GLOBAL' & goal=='Index') %>% select(center=score)), '\n'))
cat(paste('Calculated weighted average score:', round(weighted.mean(x$score, x$weight)), '\n'))
# Extracted weighted average score : 71 
# Calculated weighted average score: 69
