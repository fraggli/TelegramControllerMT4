<h1>Telegram Controller EA MT4</h1>
<h2>Help maintain and support development</h2>
Use any of the links below to help contribute to this open source project and all of my other projects too!

[![BuyMeACoffee](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-orange)](https://www.buymeacoffee.com/TomCarrForex) [![Patreon](https://img.shields.io/badge/patreon-donate-orange.svg)](https://www.patreon.com/TomCarrForex) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![platform](https://img.shields.io/badge/platform-MT4-blue)](Platform) [![vps](https://img.shields.io/badge/suggested%20vps-time4vps-green)]( 	https://www.time4vps.com/?affid=5737) [![broker](https://img.shields.io/badge/find%20a%20broker-cashback%20forex-green)](https://www.cashbackforex.com#aid_359774) [![testdata](https://img.shields.io/badge/accurate%20test%20data-tickstory-green)](https://tickstory.7eer.net/c/2693658/213763/3725) 

<h2>Why is this free?</h2>
I'm a believer in open source everything where possible. I use all the tools I create myself on live accounts to make some supplementary income. If you find the tools that I have built useful then please feel free to donate above. Although use this software at your own risk, I'm not responsible for any transactions that occur and am providing this software for free under the MIT license.

<h2>Summary</h2>

This Expert Advisor is based on the telegram.mqh provided by MetaQuotes and is a nice easy to use layer on top of the telegram RestAPI. 

The telegram controller EA enables notifications of various kinds (from open/close orders to 24 hour summary) and closing of trades, all from telegram with this EA acting like a telegram bot. All interactions are limited to the user ID's input into the MT4 EA.

This has been configured to unburden you the user as much as possible, simply follow this tutorial up to and including "Copy the access token": https://docs.microsoft.com/en-us/azure/bot-service/bot-service-channel-connect-telegram?view=azure-bot-service-4.0

Once that is done it's down to configuring the EA as you see fit, all options are detailed in the table below.

<h2>Expert Advisor Properties</h2>
<table style="width:100%">
  <tr>
    <th>Variable Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <th>ShowAccountInfoInGUI</th>
    <th>Whether to show the Account info overlayed on the chart.</th>
  </tr>
  <tr>
    <th>UpdateAccountInfoOnTick</th>
    <th>Whether to update the Account info overlayed on the chart per tick.</th>
  </tr>
  <tr>
  <th>TelegramSeperator</th>
  <th>N/A – Not used by the EA.</th>
  </tr>
  <tr>
  <th>TelegramUpdateTimingSeconds</th>
  <th>The number of seconds to get the bot to check for messages, defaulting to 3 seconds as a minimum. </th>
  </tr>
  <tr>
  <th>BotFartherGeneratedTelegramAPIToken</th>
  <th>The token HTTP API key you gained above in step 6.</th>
  </tr>
  <tr>
  <th>YourTelegramUserName</th>
  <th>To limit the interactions with this telegram bot to just you.</th>
  </tr>
  <tr>
  <th>TelegramCloseAllProtectionPassword</th>
  <th>A password to close down all of your trades with the “/CloseAllOpenOrders” command, followed by a space and the password entered here. </th>
  </tr>
  <tr>
  <th>DailyUpdateEnable</th>
  <th>Whether to enable the daily update (note these trades are all completed within the past 24 hours).</th>
  </tr>
  <tr>
  <th>DailyTimeUseGMT</th>
  <th>True – Set time to GMT time, no offset applied.
False – Set time to current time on the server where the EA is running, this is the easier option as you can set this time manually in windows.</th>
  </tr>
  <tr>
  <th>DailyUpdateHour</th>
  <th>If daily update is enabled, this is the hour time in 24 hours when the daily update will be sent.</th>
  </tr>
  <tr>
  <th>DailyUpdateMinute</th>
  <th>If daily update is enabled, this is the minute time when the daily update will be sent.</th>
  </tr>
  <tr>
  <th>NotifyAccountMargin</th>
  <th>Whether to send out a notification when the account margin threshold is exceeded, while this is true a notification will be sent every 3 minutes.</th>
  </tr>
  <tr>
  <th>NotifyAccountMarginThreshold</th>
  <th>The threshold value, when enabled if the Account Margin drops below this value, then a message alert is sent out.</th>
  </tr>
  <tr>
  <th>NotifyAccountFreeMargin</th>
  <th>Whether to send out a notification when the account free margin threshold is exceeded, while this is true a notification will be sent every 3 minutes.</th>
  </tr>
  <tr>
  <th>NotifyAccountFreeMarginThreshold</th>
  <th>The threshold value, when enabled if the Account Free Margin drops below this value, then a message alert is sent out.</th>
  </tr>
  <tr>
  <th>NotifyAccountSingleTradeLoss</th>
  <th>Whether to send out a notification when a single trade loss threshold is exceeded, while this is true a notification will be sent every 3 minutes.</th>
  </tr>
  <tr>
  <th>NotifyAccountSingleTradeLossThreshold</th>
  <th>The threshold value, when enabled if a single trade loss drops below this value, then a message alert is sent out.</th>
  </tr>
  <tr>
  <th>NotifyAccountSingleTradeProfit</th>
  <th>Whether to send out a notification when a single trade profit threshold is exceeded, while this is true a notification will be sent every 3 minutes.</th>
  </tr>
  <tr>
  <th>NotifyAccountSingleTradeProfitThreshold</th>
  <th>The threshold value, when enabled if a single trade exceeds this value, then a message alert is sent out.</th>
  </tr>
  <tr>
  <th>NotifyAccountEquityDropBelow</th>
  <th>Whether to send out a notification when the account equity threshold is exceeded, while this is true a notification will be sent every 3 minutes.</th>
  </tr>
  <tr>
  <th>NotifyAccountEquityDropBelowThreshold</th>
  <th>The threshold value, when enabled if the Account Equity drops below this value, then a message alert is sent out.</th>
  </tr>

  