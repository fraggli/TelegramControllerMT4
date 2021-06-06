/***************************************************************************************************************************
 * MIT License
 *
 * @copyright (c) - 2021 - Thomas Carr
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 * persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************************************/
#property copyright "MIT License - 2021 - Thomas Carr"
#property version   "1.00"
#property description "Telegram Controller EA"
#property strict

/***************************************************************************************************************************
 * INCLUDES
 **************************************************************************************************************************/
#include "../Include/plusinit.mqh"
#include "../Include/Telegram/Telegram.mqh"
#include "../Include/Telegram/TelegramBotInterface.mqh"

/***************************************************************************************************************************
 * TYPE DEFINITIONS
 **************************************************************************************************************************/
enum DailyUpdateType
{
    TWENTY_FOUR_HOUR_SUMMARY,
    DAY_SUMMARY
};

/***************************************************************************************************************************
 * VARIABLE DEFINITION
 **************************************************************************************************************************/
string               VersionNumber = "EA Version: 1.00";
TelegramBotInterface telegramBotObject;
const int            NumBootAttempts = 10;

/***************************************************************************************************************************
 * EXTERNAL VARIABLE DEFINITION
 **************************************************************************************************************************/
input string    SeperatorDisplay = "* * * * Display Settings * * * *";
input bool      ShowAccountInfoInGUI = false;
input bool      UpdateAccountInfoOnTick = false;
input string    TelegramSeperator = "* * * * Telegram Settings * * * *";
input int       TelegramUpdateTimingSeconds = 3;
input string    BotFartherGeneratedTelegramAPIToken = "";
input string    YourTelegramUserName = "";
input string    TelegramCloseAllProtectionPassword = "password";
input bool      TelegramBotPrintHelpAfterResponse = true;
input bool      DailyUpdateEnable = true;
input bool      DailyTimeUseGMT = true;
DailyUpdateType DailyUpdateTypeVar = TWENTY_FOUR_HOUR_SUMMARY;
input int       DailyUpdateHour = 6;
input int       DailyUpdateMinute = 0;
input string    NotifySeperator = "* * * * Notify Settings * * * *";
input int       NotifyTimeInSecondsBetweenUpdates = 300; // 5 mins
input bool      NotifyOnOrderOpen = true;
input bool      NotifyOnOrderClose = true;
input bool      NotifyAccountMargin = false;
input double    NotifyAccountMarginThreshold = 125;
input bool      NotifyAccountFreeMargin = true;
input double    NotifyAccountFreeMarginThreshold = 125;
input bool      NotifyAccountSingleTradeLoss = true;
input double    NotifyAccountSingleTradeLossThreshold = -100;
input bool      NotifyAccountSingleTradeProfit = true;
input double    NotifyAccountSingleTradeProfitThreshold = 100;
input bool      NotifyAccountEquityDropBelow = false;
input double    NotifyAccountEquityDropBelowThreshold = 125;


/***************************************************************************************************************************
 * @brief     Update information on the GUI when triggered
 **************************************************************************************************************************/
void UpdateAccountInfo(void)
{
    ObjectSetText("AccountBalance",
                  StringFormat("Account Balance: %.2f %s", AccountBalance(), AccountCurrency()),
                  8,
                  "Verdana",
                  White);
    ObjectSetText("AccountEquity", StringFormat("Account Equity: %f", AccountEquity()), 8, "Verdana", White);
    ObjectSetText("AccountMargin", StringFormat("Account Margin: %f", AccountMargin()), 8, "Verdana", White);
    ObjectSetText("AccountFreeMargin", StringFormat("Account Free Margin: %f", AccountFreeMargin()), 8, "Verdana", White);
}



/***************************************************************************************************************************
 * @brief     The GUI setup handler
 **************************************************************************************************************************/
void SetupGUI(void)
{
    string eaTitle = "Tom Carr Forex - TimedRSI EA";
    string brokerName = "Broker: ";
    string seperatorText = "-------------------------";

    color displayColour = White;
    int   yCurrentValue = 20;
    int   yOffsetValue = 12;

    // EA Title Mode
    ObjectCreate("EATitle", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("EATitle", eaTitle, 8, "Verdana", displayColour);
    ObjectSet("EATitle", OBJPROP_CORNER, 0);
    ObjectSet("EATitle", OBJPROP_XDISTANCE, 20);
    ObjectSet("EATitle", OBJPROP_YDISTANCE, yCurrentValue);

    // Version Number
    yCurrentValue += yOffsetValue;
    ObjectCreate("VersionNumber", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("VersionNumber", VersionNumber, 8, "Verdana", displayColour);
    ObjectSet("VersionNumber", OBJPROP_CORNER, 0);
    ObjectSet("VersionNumber", OBJPROP_XDISTANCE, 20);
    ObjectSet("VersionNumber", OBJPROP_YDISTANCE, yCurrentValue);

    // Seperator
    yCurrentValue += yOffsetValue;
    ObjectCreate("Seperator1", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("Seperator1", seperatorText, 8, "Verdana", displayColour);
    ObjectSet("Seperator1", OBJPROP_CORNER, 0);
    ObjectSet("Seperator1", OBJPROP_XDISTANCE, 20);
    ObjectSet("Seperator1", OBJPROP_YDISTANCE, yCurrentValue);

    // Broker Name
    yCurrentValue += yOffsetValue;
    brokerName += AccountCompany();
    ObjectCreate("BrokerName", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("BrokerName", brokerName, 8, "Verdana", displayColour);
    ObjectSet("BrokerName", OBJPROP_CORNER, 0);
    ObjectSet("BrokerName", OBJPROP_XDISTANCE, 20);
    ObjectSet("BrokerName", OBJPROP_YDISTANCE, yCurrentValue);

    // Account Balance
    yCurrentValue += yOffsetValue;
    ObjectCreate("AccountBalance", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("AccountBalance", "", 8, "Verdana", displayColour);
    ObjectSet("AccountBalance", OBJPROP_CORNER, 0);
    ObjectSet("AccountBalance", OBJPROP_XDISTANCE, 20);
    ObjectSet("AccountBalance", OBJPROP_YDISTANCE, yCurrentValue);

    // Account Equity
    yCurrentValue += yOffsetValue;
    ObjectCreate("AccountEquity", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("AccountEquity", "", 8, "Verdana", displayColour);
    ObjectSet("AccountEquity", OBJPROP_CORNER, 0);
    ObjectSet("AccountEquity", OBJPROP_XDISTANCE, 20);
    ObjectSet("AccountEquity", OBJPROP_YDISTANCE, yCurrentValue);

    // Account Margin
    yCurrentValue += yOffsetValue;
    ObjectCreate("AccountMargin", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("AccountMargin", "", 8, "Verdana", displayColour);
    ObjectSet("AccountMargin", OBJPROP_CORNER, 0);
    ObjectSet("AccountMargin", OBJPROP_XDISTANCE, 20);
    ObjectSet("AccountMargin", OBJPROP_YDISTANCE, yCurrentValue);

    // Account Free Margin
    yCurrentValue += yOffsetValue;
    ObjectCreate("AccountFreeMargin", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("AccountFreeMargin", "", 8, "Verdana", displayColour);
    ObjectSet("AccountFreeMargin", OBJPROP_CORNER, 0);
    ObjectSet("AccountFreeMargin", OBJPROP_XDISTANCE, 20);
    ObjectSet("AccountFreeMargin", OBJPROP_YDISTANCE, yCurrentValue);

    if (ShowAccountInfoInGUI)
    {
        UpdateAccountInfo();
    }
}



/***************************************************************************************************************************
 * @brief     Manage the notifications to be sent over telegram.
 **************************************************************************************************************************/
void NotificationManager(void)
{
    static datetime LastNotifyMargin;
    static datetime LastNotifyFreeMargin;
    static datetime LastNotifySingleTradeWorst;
    static datetime LastNotifySingleTradeBest;
    static datetime LastNotifyEquity;
    int             tradePosition = -1;
    double          tradeProfit = 0;
    static int      totalOrders = 0;


    if (NotifyOnOrderOpen)
    {
        if (totalOrders < OrdersTotal())
        {
            for (int i = 0; i < (OrdersTotal() - totalOrders); ++i)
            {
                telegramBotObject.NotifyNewOrder(OrdersTotal() - 1 - i);
            }

            totalOrders = OrdersTotal();
        }
    }

    if (NotifyOnOrderClose)
    {
        if (totalOrders > OrdersTotal())
        {
            for (int i = 0; i < (totalOrders - OrdersTotal()); ++i)
            {
                telegramBotObject.NotifyCloseOrder(OrdersHistoryTotal() - 1 - i);
            }

            totalOrders = OrdersTotal();
        }
    }

    if (  NotifyAccountMargin
       && AccountMargin() <= NotifyAccountMarginThreshold)
    {
        datetime TimeCurrentVal = TimeCurrent();
        double   timeGap = TimeCurrentVal - LastNotifyMargin;

        if (timeGap > NotifyTimeInSecondsBetweenUpdates)
        {
            telegramBotObject.NotifyMargin();
            LastNotifyMargin = TimeCurrent();
        }

    }

    if (  NotifyAccountFreeMargin
       && AccountFreeMargin() <= NotifyAccountFreeMarginThreshold)
    {
        datetime TimeCurrentVal = TimeCurrent();
        double   timeGap = TimeCurrentVal - LastNotifyFreeMargin;

        if (timeGap > NotifyTimeInSecondsBetweenUpdates)
        {
            telegramBotObject.NotifyFreeMargin();
            LastNotifyFreeMargin = TimeCurrent();
        }

    }

    if (NotifyAccountSingleTradeLoss)
    {
        tradeProfit = AccountWorstTrade(tradePosition);

        if (tradeProfit <= NotifyAccountSingleTradeLossThreshold)
        {
            datetime TimeCurrentVal = TimeCurrent();
            double   timeGap = TimeCurrentVal - LastNotifySingleTradeWorst;

            if (timeGap > NotifyTimeInSecondsBetweenUpdates)
            {
                telegramBotObject.NotifyWorstTrade(tradeProfit, tradePosition);
                LastNotifySingleTradeWorst = TimeCurrent();
            }
        }
    }


    if (NotifyAccountSingleTradeProfit)
    {
        tradeProfit = AccountBestTrade(tradePosition);

        if (tradeProfit >= NotifyAccountSingleTradeProfitThreshold)
        {
            datetime TimeCurrentVal = TimeCurrent();
            double   timeGap = TimeCurrentVal - LastNotifySingleTradeBest;

            if (timeGap > (NotifyTimeInSecondsBetweenUpdates))
            {
                telegramBotObject.NotifyBestTrade(tradeProfit, tradePosition);
                LastNotifySingleTradeBest = TimeCurrent();
            }
        }
    }

    if (  NotifyAccountEquityDropBelow
       && AccountEquity() <= NotifyAccountEquityDropBelowThreshold)
    {
        datetime TimeCurrentVal = TimeCurrent();
        double   timeGap = TimeCurrentVal - LastNotifyEquity;

        if (timeGap > (NotifyTimeInSecondsBetweenUpdates))
        {
            telegramBotObject.NotifyEquity();
            LastNotifyEquity = TimeCurrent();
        }
    }
}



/***************************************************************************************************************************
 * @brief     Get Worst Open Trade Position
 **************************************************************************************************************************/
double AccountWorstTrade(int &position)
{
    double retVal = 0;
    double orderProfit = 0;

    if (OrdersTotal() > 0)
    {
        retVal = 10000000;

        for (int i = 0; i < OrdersTotal(); ++i)
        {
            if (OrderSelect(i, SELECT_BY_POS))
            {
                orderProfit = OrderProfit() - OrderSwap() - OrderCommission();

                if (orderProfit < retVal)
                {
                    retVal = orderProfit;
                    position = i;
                }
            }
        }
    }

    return retVal;
}



/***************************************************************************************************************************
 * @brief     Get Best Open Trade Position
 **************************************************************************************************************************/
double AccountBestTrade(int &position)
{
    double retVal = 0;
    double orderProfit = 0;

    if (OrdersTotal() > 0)
    {
        retVal = -10000000;

        for (int i = 0; i < OrdersTotal(); ++i)
        {
            if (OrderSelect(i, SELECT_BY_POS))
            {
                orderProfit = OrderProfit() - OrderSwap() - OrderCommission();

                if (orderProfit > retVal)
                {
                    retVal = orderProfit;
                    position = i;
                }
            }
        }
    }

    return retVal;
}



/***************************************************************************************************************************
 * @brief     Main tick functionality.
 **************************************************************************************************************************/
void MainTickProcess(void)
{
    telegramBotObject.GetUpdates();
    telegramBotObject.ProcessMessages(TelegramCloseAllProtectionPassword, TelegramBotPrintHelpAfterResponse);
}



/***************************************************************************************************************************
 * @brief     The initialisation function.
 **************************************************************************************************************************/
int OnInit(void)
{
    EventSetTimer(TelegramUpdateTimingSeconds);
    int intResult = 0;

    telegramBotObject.Token(BotFartherGeneratedTelegramAPIToken);

    for (int i = 0; i < NumBootAttempts; ++i)
    {
        intResult = telegramBotObject.GetMe();

        if (0 == intResult)
        {
            break;
        }

        PrintFormat("Web Request Error: %d.", intResult);
    }

    if ("" == YourTelegramUserName)
    {
        MessageBox(
            "You have not entered your Telegram User Name, please do so or anyone will be able to interact with this robot.",
            "Missing Telegram User Name",
            MB_OK | MB_ICONERROR);
        DeInitGUI();
        return INIT_FAILED;
    }

    if ("" == BotFartherGeneratedTelegramAPIToken)
    {
        MessageBox(
            "You have not entered your Telegram API Token, please follow the instructions to get an API token at: https://docs.microsoft.com/en-us/azure/bot-service/bot-service-channel-connect-telegram?view=azure-bot-service-4.0",
            "Missing Telegram API Token",
            MB_OK | MB_ICONERROR);
        DeInitGUI();
        return INIT_FAILED;
    }

    if (TelegramUpdateTimingSeconds < 3)
    {
        MessageBox(
            "Please enter TelegramUpdateTimingSeconds that is greater than 3.",
            "TelegramUpdateTimingSeconds Not Large Enough",
            MB_OK | MB_ICONERROR);
        DeInitGUI();
        return INIT_FAILED;
    }

    if (DailyUpdateEnable)
    {
        if (DailyUpdateHour > 23)
        {
            MessageBox(
                "Please enter DailyUpdateHour that is less than 23.",
                "DailyUpdateHour Too Large",
                MB_OK | MB_ICONERROR);
            DeInitGUI();
            return INIT_FAILED;
        }

        if (DailyUpdateMinute > 59)
        {
            MessageBox(
                "Please enter DailyUpdateMinute that is less than 59.",
                "DailyUpdateMinute Too Large",
                MB_OK | MB_ICONERROR);
            DeInitGUI();
            return INIT_FAILED;
        }
    }

    if (NotifyAccountMargin)
    {
        if (NotifyAccountMarginThreshold <= 0)
        {
            MessageBox(
                "Please enter NotifyAccountMarginThreshold that is greater than 0.",
                "NotifyAccountMarginThreshold Too Small",
                MB_OK | MB_ICONERROR);
            DeInitGUI();
            return INIT_FAILED;
        }
    }

    if (NotifyAccountFreeMargin)
    {
        if (NotifyAccountFreeMarginThreshold <= 0)
        {
            MessageBox(
                "Please enter NotifyAccountFreeMarginThreshold that is greater than 0.",
                "NotifyAccountFreeMarginThreshold Too Small",
                MB_OK | MB_ICONERROR);
            DeInitGUI();
            return INIT_FAILED;
        }
    }

    if (NotifyAccountSingleTradeLoss)
    {
        if (NotifyAccountSingleTradeLossThreshold >= 0)
        {
            MessageBox(
                "Please enter NotifyAccountSingleTradeLossThreshold that is less than 0.",
                "NotifyAccountSingleTradeLossThreshold Too Small",
                MB_OK | MB_ICONERROR);
            DeInitGUI();
            return INIT_FAILED;
        }
    }

    if (NotifyAccountSingleTradeProfit)
    {
        if (NotifyAccountSingleTradeProfitThreshold <= 0)
        {
            MessageBox(
                "Please enter NotifyAccountSingleTradeProfitThreshold that is greater than 0.",
                "NotifyAccountSingleTradeProfitThreshold Too Small",
                MB_OK | MB_ICONERROR);
            DeInitGUI();
            return INIT_FAILED;
        }
    }

    if (NotifyAccountEquityDropBelow)
    {
        if (NotifyAccountEquityDropBelowThreshold <= 0)
        {
            MessageBox(
                "Please enter NotifyAccountEquityDropBelowThreshold that is greater than 0.",
                "NotifyAccountEquityDropBelowThreshold Too Small",
                MB_OK | MB_ICONERROR);
            DeInitGUI();
            return INIT_FAILED;
        }
    }

    if (0 == intResult)
    {
        telegramBotObject.UserNameFilter(YourTelegramUserName);

        ObjectSetText("BotName", StringFormat("Bot Name: %s", telegramBotObject.Name()), 8, "Verdana", White);

        string notificationHelp = "Please send a message to ";
        StringAdd(notificationHelp, telegramBotObject.Name());
        StringAdd(notificationHelp,
                  " to allow telegram messages to be sent back to you. Note: this happens everytime the EA is changed or rebooted.");

        SendNotification(notificationHelp);
        MessageBox(
            notificationHelp,
            "Telegram Bot Started",
            MB_OK);
    }
    else
    {
        MessageBox(
            "Web Request Error, Ensure the Web URL https://api.telegram.org is allowed in EA settings.",
            "Web Request Error",
            MB_OK | MB_ICONERROR);
        DeInitGUI();
        return(INIT_FAILED);
    }



    return(INIT_SUCCEEDED);
}



/***************************************************************************************************************************
 * @brief     Deinit the display on the terminal
 **************************************************************************************************************************/
void DeInitGUI(void)
{
    ObjectDelete("EATitle");
    ObjectDelete("VersionNumber");
    ObjectDelete("AccountMode");
    ObjectDelete("SubscriptionStatus");
    ObjectDelete("Seperator1");
    ObjectDelete("BrokerName");
    ObjectDelete("AccountBalance");
    ObjectDelete("AccountEquity");
    ObjectDelete("AccountMargin");
    ObjectDelete("AccountFreeMargin");
    EventKillTimer();
    ExpertRemove();
}



/***************************************************************************************************************************
 * @brief     Deinit function provided by MT4
 **************************************************************************************************************************/
void OnDeinit(const int reason)
{
    DeInitGUI();
}



/***************************************************************************************************************************
 * @brief     A tick function to execute on tick event.
 **************************************************************************************************************************/
void OnTick(void)
{
    if (  ShowAccountInfoInGUI
       && UpdateAccountInfoOnTick
       && !IsTesting())
    {
        UpdateAccountInfo();
    }

    NotificationManager();
}



/***************************************************************************************************************************
 * @brief     A timer function to execute on timer expiry.
 **************************************************************************************************************************/
void OnTimer(void)
{
    static bool sentNotification = false;

    MainTickProcess();

    if (DailyUpdateEnable)
    {
        datetime timeCurrent;

        if (DailyTimeUseGMT)
        {
            timeCurrent = TimeGMT();
        }
        else
        {
            timeCurrent = TimeCurrent();
        }

        if (  TimeHour(timeCurrent) == DailyUpdateHour
           && TimeMinute(timeCurrent) == DailyUpdateMinute)
        {
            if (!sentNotification)
            {
                if (TWENTY_FOUR_HOUR_SUMMARY == DailyUpdateTypeVar)
                {
                    telegramBotObject.AccountSummary24Hour();
                }

                sentNotification = true;
            }
        }
        else
        {
            sentNotification = false;
        }
    }
}
