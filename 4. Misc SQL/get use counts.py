counts=data_filtered.value_counts(["var", "user_clicked"]).reset_index()

counts_wide=counts.pivot_table(index="var", columns="user_clicked", values=0).reset_index()

counts_wide["total"]=counts_wide[0]+counts_wide[1]

counts_wide["Percent"]=counts_wide[1]/counts_wide["total"]

ping.ttest(counts_wide["Percent"], 0.0025, paired=False, alternative='greater', correction='auto', r=0.707, confidence=0.95) 
