SELECT Campaign, sum(Revenue) as "Revenue ", sum(EventsCount) as "Events Count", sum(TotalCost) as "Total Cost", sum(Revenue)/sum(TotalCost)*100 as ROAS FROM
	(SELECT
		VisitorId,
		sum(EventCost) as Revenue,
		countIf(EventName = '$EventName') as EventsCount
		FROM $table
		PREWHERE
		EventReceiveDate >= '${__from:date:YYYY-MM-DD hh-mm-ss}'
		AND EventReceiveDate <= toDate('${__to:date:YYYY-MM-DD hh-mm-ss}') + INTERVAL $CohortSize day
		AND EventName like '$EventName'
		Group By VisitorId
	) RevenueSrc

INNER JOIN

	(SELECT dictGetString('campaign', 'FullName', cityHash64(CampaignId)) as Campaign,
		VisitorId,
		EventDate as InstallDate
		FROM $table
		PREWHERE
		Date >= '${__from:date:YYYY-MM-DD hh-mm-ss}'
		AND Date <= '${__to:date:YYYY-MM-DD hh-mm-ss}'
		AND AdvertiserId = trimBoth('$AdvertiserID')
		AND TradingDeskId='5ebbd5553cbe226f08c69004'
		GROUP BY CampaignId,
		VisitorId,
		EventDate
	) CohortSrc ON RevenueSrc.VisitorId = CohortSrc.VisitorId

INNER JOIN

	( SELECT
		dictGetString('campaign', 'FullName', cityHash64(CampaignId)) as Campaign,
		sum(WinsSum) as TotalCost
		FROM $table
		PREWHERE
		Date >= '${__from:date:YYYY-MM-DD hh-mm-ss}'
		AND Date <= '${__to:date:YYYY-MM-DD hh-mm-ss}'
		AND AdvertiserId = trimBoth('$AdvertiserID')
		AND TradingDeskId='5ebbd5553cbe226f08c69004'
		GROUP by Campaign
	) CostSrc ON CohortSrc.Campaign = CostSrc.Campaign 

Group By Campaign
