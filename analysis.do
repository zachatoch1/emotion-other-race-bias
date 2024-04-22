* Zach Abrams
* EC970 Paper Analysis
* GEN AI

*clear the workspace 
clear all 
version 18 

* change to the working directory
cd "~/desktop/PAPER"

*start a log file 
capture log close

log using output/zachabrams_paper.log, replace


* read in the data
use "rawdata/analysis_data.dta", clear

* generate summary statistics
outreg2 using output/table1.doc, replace sum(log) title("Table 1. Summary Statistics All Data")

***********************************************
*    			Graph Data					  *
***********************************************


* GRAPH DISTRIBUTION OF ANSWERS BY EMOTION CONGRUENCE
gen ec_labeled = "emotional incongruency"
replace ec_labeled = "emotional congruency" if emotion_congruence == 1
* generate violin plots
* emotion_congruence
vioplot rating, over(ec_labeled) name(vplot, replace) ///
  vertical ylabel(, angle(horizontal) labsize(small)) ///
  xlabel(,labsize(small)) title("Figure 1: Violin Plot of Rating by Emotion Congruence", size(medium)) ///
  color(ltblue) bw(0.5) scheme(s1mono)
graph export "output/fig_1_vio_ec.png", replace


* GRAPH DISTRIBUTION OF ANSWERS BY RATER RACE
* rater race
* generating categorical
gen rater_race = ""
replace rater_race = "white" if is_rater_white == 1
replace rater_race = "black" if is_rater_black == 1
replace rater_race = "default" if is_rater_default == 1
* make plot
vioplot rating if emotion_congruence == 1, over(rater_race) name(vplot, replace) ///
  vertical ylabel(, angle(horizontal) labsize(small)) ///
  xlabel(,labsize(small)) title("Figure 2: Violin Plot of Rating by Rater Race (EC == 1)", size(medium)) ///
  color(ltblue) bw(0.5) scheme(s1mono)
graph export "output/fig_2_vio_rater_race.png", replace


* GRAPH DISTRIBUTION OF ANSWERS BY RATER RACE
gen image_race = "black"
replace image_race = "white" if is_image_white == 1
* image races
vioplot rating, over(image_race) name(vplot, replace) ///
  vertical ylabel(, angle(horizontal) labsize(small)) ///
  xlabel(,labsize(small)) title("Figure 3: Violin Plot of Rating by Image Race", size(medium)) ///
  color(ltblue) bw(0.5) scheme(s1mono)
graph export "output/fig_3_vio_image_race.png", replace


* GRAPH DISTRIBUTION OF ANSWERS BY IMAGE IF EC = 1 ONLY
* by image
gen image_unique = ""
replace image_unique = "Happy_W" if is_image_white == 1 & image_emotion_happy == 1 & emotion_congruence == 1
replace image_unique = "Happy_B" if is_image_white == 0 & image_emotion_happy == 1 & emotion_congruence == 1
replace image_unique = "Sad_W" if is_image_white == 1 & image_emotion_sad == 1 & emotion_congruence == 1
replace image_unique = "Sad_B" if is_image_white == 0 & image_emotion_sad == 1 & emotion_congruence == 1
replace image_unique = "Angry_W" if is_image_white == 1 & image_emotion_angry == 1 & emotion_congruence == 1
replace image_unique = "Angry_B" if is_image_white == 0 & image_emotion_angry == 1 & emotion_congruence == 1

* by unique image
vioplot rating, over(image_unique) name(vplot, replace) ///
  vertical ylabel(, angle(horizontal) labsize(small)) ///
  xlabel(,labsize(small)) title("Figure 4: Violin Plot of Rating by Image (EC == 1)", size(medium)) ///
  color(ltblue) bw(0.5) scheme(s1mono)
graph export "output/fig_4_vio_image_ec.png", replace

  
  
  
  
 
 
 
***********************************************
*    			Run Regressions				  *
***********************************************

* Analysis #1 Emotion Congruence Analysis
* reg 1
reg rating emotion_congruence is_rater_white is_rater_default is_image_white image_emotion_angry image_emotion_sad, r
outreg2 using output/table2.doc, replace nonotes title("Table 2: Emotion Image/Ask Congruence") ctitle("Rating") dec(3) addtext(Rater Race, All, Image Race, All) addnote("Notes: Standard errors are given in parentheses under estimated coefficients. Standard errors are heteroskedasticity-robust (HR) for all regressions. All regressions are estimated using ordinary least squares. Coefficients are individually statistically significant at the *10%, **5%, ***1% significance level.") drop(o.image_emotion_sad)

* reg 2
reg rating emotion_congruence is_rater_white is_rater_default is_image_white image_emotion_angry image_emotion_sad if is_image_white == 1, r
outreg2 using output/table2.doc, append nonotes ctitle("Rating") dec(3) addtext(Rater Race, All, Image Race, White) drop(o.is_image_white)

* reg 3
reg rating emotion_congruence is_rater_white is_rater_default is_image_white image_emotion_angry image_emotion_sad if is_image_white == 0, r
outreg2 using output/table2.doc, append nonotes ctitle("Rating") dec(3) addtext(Rater Race, All, Image Race, Black) drop(o.is_image_white)

* reg 4
reg rating emotion_congruence is_rater_white is_rater_default is_image_white image_emotion_angry image_emotion_sad if is_rater_white == 1 & is_rater_default == 0, r
outreg2 using output/table2.doc, append nonotes ctitle("Rating") dec(3) addtext(Rater Race, White, Image Race, All) drop(o.is_rater_white o.is_rater_default)

* reg 5
reg rating emotion_congruence is_rater_white is_rater_default is_image_white image_emotion_angry image_emotion_sad if is_rater_white == 0 & is_rater_default == 0, r
outreg2 using output/table2.doc, append nonotes ctitle("Rating") dec(3) addtext(Rater Race, Black, Image Race, All) drop(o.is_rater_white o.is_rater_default)

* reg 6
reg rating emotion_congruence is_rater_white is_rater_default is_image_white image_emotion_angry image_emotion_sad if is_rater_default == 1, r
outreg2 using output/table2.doc, append nonotes ctitle("Rating") dec(3) addtext(Rater Race, Default, Image Race, All) drop(o.is_rater_white o.is_rater_default)


* Analysis #2 Other Race Effect Analysis
* generate a same race binary
gen same_race = 0
replace same_race = 1 if is_image_white == 1 & is_rater_white == 1
replace same_race = 1 if is_image_black == 1 & is_rater_black == 1
*reg 1
reg rating other_race same_race emotion_congruence is_image_white image_emotion_angry image_emotion_sad image_emotion_happy, r
test other_race = same_race, df(1e10)
scalar f_stat = r(F)
scalar p_value = r(p)
outreg2 using output/table3.doc, replace nonotes title("Table 3: Other Race Effect") ctitle("Rating") dec(3) addtext(Rater Race, All) addstat("F-statistic for other-race same-race heterogeneity", f_stat, "P-value", p_value) addnote("Notes: Standard errors are given in parentheses under estimated coefficients. Standard errors are heteroskedasticity-robust (HR) for all regressions. All regressions are estimated using ordinary least squares. Coefficients are individually statistically significant at the *10%, **5%, ***1% significance level.")

*reg 2
reg rating other_race same_race emotion_congruence is_image_white image_emotion_angry image_emotion_sad image_emotion_happy if is_rater_white == 1 | is_rater_default == 1, r
test other_race = same_race, df(1e10)
scalar f_stat = r(F)
scalar p_value = r(p)
outreg2 using output/table3.doc, append nonotes ctitle("Rating") dec(3) addtext(Rater Race, White or Default) addstat("F-statistic for other-race same-race heterogeneity", f_stat, "P-value", p_value)

*reg 3
reg rating other_race same_race emotion_congruence is_image_white image_emotion_angry image_emotion_sad image_emotion_happy if is_rater_white == 0 | is_rater_default == 1, r
test other_race = same_race, df(1e10)
scalar f_stat = r(F)
scalar p_value = r(p)
outreg2 using output/table3.doc, append nonotes ctitle("Rating") dec(3) addtext(Rater Race, Black or Default) addstat("F-statistic for other-race same-race heterogeneity", f_stat, "P-value", p_value)


* Analysis #3 General Effect of Rater Race
* reg 1
reg rating is_rater_white is_rater_black is_image_white image_emotion_angry image_emotion_sad image_emotion_happy if emotion_congruence == 1, r
test is_rater_white = is_rater_black, df(1e10)
scalar f_stat = r(F)
scalar p_value = r(p)

outreg2 using output/table4.doc, replace nonotes title("Table 4: Rater Race Effect") ctitle("Rating") dec(3) addtext(Emotion Congruence, 1) addstat("F-statistic for white-rater black-rater heterogeneity", f_stat, "P-value", p_value) addnote("Notes: Standard errors are given in parentheses under estimated coefficients. Standard errors are heteroskedasticity-robust (HR) for all regressions. All regressions are estimated using ordinary least squares. Coefficients are individually statistically significant at the *10%, **5%, ***1% significance level.")
* reg 2
reg rating is_rater_white is_rater_black is_image_white image_emotion_angry image_emotion_sad image_emotion_happy if emotion_congruence == 0, r
test is_rater_white = is_rater_black, df(1e10)
scalar f_stat = r(F)
scalar p_value = r(p)

outreg2 using output/table4.doc, append nonotes ctitle("Rating") dec(3) addtext(Emotion Congruence, 0) addstat("F-statistic for white-rater black-rater heterogeneity", f_stat, "P-value", p_value)


* reg 3
reg rating is_rater_white is_rater_black emotion_congruence is_image_white image_emotion_angry image_emotion_sad image_emotion_happy, r
test is_rater_white = is_rater_black, df(1e10)
scalar f_stat = r(F)
scalar p_value = r(p)

outreg2 using output/table4.doc, append nonotes ctitle("Rating") dec(3) addtext(Emotion Congruence, All) addstat("F-statistic for white-rater black-rater heterogeneity", f_stat, "P-value", p_value)


* Analysis #4 Effect of EC interactions
reg rating b1.emotion_congruence##is_rater_white b1.emotion_congruence##is_rater_black is_image_white image_emotion_angry image_emotion_happy image_emotion_sad, r

outreg2 using output/table4.doc, append nonotes ctitle("Rating") dec(3) addtext(Emotion Congruence, All)
* close log
cap log close
