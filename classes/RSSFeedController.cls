global with sharing class RSSFeedController {
	
	public RSSFeedController() {}

	@RemoteAction
	global static FeedWrapper getFeeds() {

		try {
			List<RSSFeed__c> feeds = [select id, name, feed_description__c, feed_url__c, feed_xml__c from RSSFeed__c where OwnerId = :UserInfo.getUserId() limit 20]; 
			List<AggregateResult> results = [select count(id) from RSSFeed__c where OwnerId = :UserInfo.getUserId()];
			Integer numberOfFeeds = ((results.size() > 0) ? (Integer)results[0].get('expr0') : 0);

			FeedWrapper w = new FeedWrapper();
			w.feeds = feeds;
			w.numberOfFeeds = numberOfFeeds;

			return w;
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Error retrieving RSSFeeds for User ['+UserInfo.getUserId()+']');
			System.debug(LoggingLevel.ERROR, e.getMessage());
			System.debug(LoggingLevel.ERROR, e.getStackTraceString());
		}
		return null;
	}

	@RemoteAction
	global static RSSFeed__c addFeed(String feedName, String feedURL) {

		if(feedName != null && feedURL != null) {
			List<AggregateResult> ag = [select count(id)found from RSSFeed__c where feed_url__c = :feedURL];
			if((Integer)ag[0].get('found') == 0) {
				RSSFeed__c f = new RSSFeed__c(name = feedName, feed_url__c = feedURL);
				try {
					insert f;
					return f;
				} catch (Exception e) {
					System.debug(LoggingLevel.ERROR, 'Unable to create RSSFeed__c for Name ['+feedName+'] URL ['+feedURL+']');
					System.debug(LoggingLevel.ERROR, e.getMessage());
					System.debug(LoggingLevel.ERROR, e.getStackTraceString());
				}
			}
		}	
		return null;
	}

	@RemoteAction
	global static boolean removeFeed(String feedId) {

		try {
			if(feedId instanceOf Id) {
				delete [select id from RSSFeed__c where id = :feedId];
				return true;
			} else {
				System.debug(LoggingLevel.ERROR, 'Feed ID ['+feedId+'] parameter is not a Salesforce ID');
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Unable to delete RSSFeed__c with id ['+feedId+']');
			System.debug(LoggingLevel.ERROR, e.getMessage());
			System.debug(LoggingLevel.ERROR, e.getStackTraceString());
		}
		return false;
	}


	global class FeedWrapper {
		public List<RSSFeed__c> feeds {get; set;}
		public Integer numberOfFeeds {get; set;}

		public FeedWrapper() {}
	}
}