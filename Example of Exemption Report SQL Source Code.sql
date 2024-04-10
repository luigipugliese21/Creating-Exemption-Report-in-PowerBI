   select     
	   i.CallDateTime,
	   i.TransactionID,
	   i.AdvertiserCampaignName,
	   i.AdvertiserName
 

into #invoca

 

from [Integration].[InvocaTransactions] i
outer apply (
              select top 1 i2.TransactionID as firstlegid, i2.CallID
			  from [Integration].[InvocaTransactions] i2
			  where i.CallID = i2.CallID
			       and (isnumeric(i2.dnis) = 1 or patindex('[0-9]%s%[0-9]', i2.DNIS) > 0)
			  order by i2.CallDateTime

 

			  ) o

where i.TransactionID = firstlegid


select i.AdvertiserCampaignName as InvocaAdvertiserCampaign,
       count(*) as Frequency,
	   sum(case when i.CallDateTime between dateadd(day,datediff(day,15,dbo.fn_utc_to_edt(getdate())),0) and dbo.fn_utc_to_edt(getdate())
	             then 1
				 else 0 end) as CallsLast15Days,
       min(i.CallDateTime) as FirstEntryDateTime,
	   max(i.CallDateTime) as LastEntryDateTime
from #invoca i with(nolock)
left join lkp.InvocaCampaignMap i2 on i.AdvertiserCampaignName = i2.CampaignName
where i2.CampaignName is null
group by i.AdvertiserCampaignName

drop table #invoca