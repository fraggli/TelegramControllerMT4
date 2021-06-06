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
#property strict

/***************************************************************************************************************************
 * INCLUDES
 **************************************************************************************************************************/
#include "Telegram.mqh"

/***************************************************************************************************************************
 * TYPE DEFINITIONS
 **************************************************************************************************************************/

/***************************************************************************************************************************
 * VARIABLE DEFINITION
 **************************************************************************************************************************/
#define NEWLINE '\n'

/***************************************************************************************************************************
 * EXTERNAL VARIABLE DEFINITION
 **************************************************************************************************************************/

class TelegramBotInterface: public CCustomBot
{
public:
    /***************************************************************************************************************************
     * @brief     Process incoming telegram messages
     **************************************************************************************************************************/
    void ProcessMessages(string ProtectionPassword, bool PrintHelpAfterResponse)
    {
        string       retVal = NEWLINE;
        const string strCloseOpenOrder = "/CloseOpenOrder";
        const string strCloseAllOpenOrders = "/CloseAllOpenOrders";
        int          pos = 0;
        int          ticket = 0;
        bool         sendHelp = false;

        for (int i = 0; i < m_chats.Total(); ++i)
        {
            CCustomChat * chat = m_chats.GetNodeAtIndex(i);

            if (!chat.m_new_one.done)
            {
                chat.m_new_one.done = true;
                chatID = chat.m_id;

                string text = chat.m_new_one.message_text;

                if ("/TotalOpenOrders" == text)
                {
                    SendMessage(chat.m_id, OpenOrdersTotal());

                    if (PrintHelpAfterResponse)
                    {
                        sendHelp = true;
                    }
                }

                if ("/OpenOrdersList" == text)
                {
                    if (OrdersTotal() > 0)
                    {
                        for (int i = 0; i < OrdersTotal(); ++i)
                        {
                            SendMessage(chat.m_id, OrderSingleTrade(i));
                        }
                    }
                    else
                    {
                        SendMessage(chat.m_id, "No Open Orders");
                    }

                    if (PrintHelpAfterResponse)
                    {
                        sendHelp = true;
                    }
                }

                if (StringFind(text, strCloseOpenOrder) >= 0)
                {
                    pos = StringToInteger(StringSubstr(text, StringLen(strCloseOpenOrder)));
                    SendMessage(chat.m_id, CloseSingleTrade(pos));

                    if (PrintHelpAfterResponse)
                    {
                        sendHelp = true;
                    }
                }

                if (StringFind(text, strCloseAllOpenOrders) >= 0)
                {
                    string providedPassword = StringSubstr(text, StringLen(strCloseAllOpenOrders) + 1);

                    if (ProtectionPassword == providedPassword)
                    {
                        for (int i = OrdersTotal(); i >= 0; --i)
                        {
                            SendMessage(chat.m_id, CloseSingleTrade(i));
                        }
                    }
                    else
                    {
                        if (0 != StringLen(providedPassword))
                        {
                            SendMessage(chat.m_id, "Password Incorrect");
                        }
                    }

                    if (PrintHelpAfterResponse)
                    {
                        sendHelp = true;
                    }
                }


                if ("/TotalClosedOrders" == text)
                {
                    SendMessage(chat.m_id, OrderHistoryTotal());

                    if (PrintHelpAfterResponse)
                    {
                        sendHelp = true;
                    }
                }

                if ("/ClosedOrdersList" == text)
                {
                    if (OrdersHistoryTotal() > 0)
                    {
                        for (int i = 0; i < OrdersHistoryTotal(); ++i)
                        {
                            SendMessage(chat.m_id, OrderHistoryTicket(i));
                        }
                    }
                    else
                    {
                        SendMessage(chat.m_id, "No Closed Orders");
                    }

                    if (PrintHelpAfterResponse)
                    {
                        sendHelp = true;
                    }
                }

                if ("/AccountDetails" == text)
                {
                    SendMessage(chat.m_id, AccountInfoReturn());

                    if (PrintHelpAfterResponse)
                    {
                        sendHelp = true;
                    }
                }

                if ("/CloseOpenOrder" == text)
                {
                    SendMessage(chat.m_id, AccountInfoReturn());

                    if (PrintHelpAfterResponse)
                    {
                        sendHelp = true;
                    }
                }


                if (  "/help" == text
                   || "/start" == text)
                {
                    sendHelp = true;
                }

                if (sendHelp)
                {
                    retVal = StringConcatenate(retVal, "Telegram Controller EA Commands List:", NEWLINE);
                    retVal = StringConcatenate(retVal, "/AccountDetails - Return account info", NEWLINE);
                    retVal = StringConcatenate(retVal, "/TotalOpenOrders - Return count of open orders", NEWLINE);
                    retVal = StringConcatenate(retVal, "/OpenOrdersList - Return ALL opened orders", NEWLINE);
                    retVal = StringConcatenate(retVal,
                                               "/CloseOpenOrder<position in list> - Close single order from list",
                                               NEWLINE);
                    retVal = StringConcatenate(retVal, "/TotalClosedOrders - Return count of the closed orders", NEWLINE);
                    retVal = StringConcatenate(retVal, "/ClosedOrdersList - Return all closed tickets", NEWLINE);
                    retVal = StringConcatenate(retVal,
                                               "/CloseAllOpenOrders <password> - Close all open orders if the password matches",
                                               NEWLINE);
                    retVal = StringConcatenate(retVal, "/help - Get the list of commands");
                    SendMessage(chat.m_id, retVal);
                }
            }
        }
    }



    /***************************************************************************************************************************
     * @brief     Generate a 24 hour account summary
     **************************************************************************************************************************/
    void AccountSummary24Hour(void)
    {
        SendMessage(chatID, AccountInfoReturnSummary24Hour());
    }



    /***************************************************************************************************************************
     * @brief     Notify on new order
     **************************************************************************************************************************/
    void NotifyNewOrder(int i)
    {
        SendMessage(chatID, AccountNewOpenOrder(i));
    }



    /***************************************************************************************************************************
     * @brief     Notify on close order
     **************************************************************************************************************************/
    void NotifyCloseOrder(int i)
    {
        SendMessage(chatID, AccountNewCloseOrder(i));
    }



    /***************************************************************************************************************************
     * @brief     Notify on margin pass threshold
     **************************************************************************************************************************/
    void NotifyMargin(void)
    {
        SendMessage(chatID, AccountMarginMessage());
    }



    /***************************************************************************************************************************
     * @brief     Notify on free margin pass threshold
     **************************************************************************************************************************/
    void NotifyFreeMargin(void)
    {
        SendMessage(chatID, AccountFreeMarginMessage());
    }



    /***************************************************************************************************************************
     * @brief     Send worst trade info out
     **************************************************************************************************************************/
    void NotifyWorstTrade(double worstTradeProfit, int worstTradePosition)
    {
        SendMessage(chatID, AccountWorstTradeMessage(worstTradeProfit, worstTradePosition));
    }



    /***************************************************************************************************************************
     * @brief     Send best trade info out
     **************************************************************************************************************************/
    void NotifyBestTrade(double bestTradeProfit, int bestTradePosition)
    {
        SendMessage(chatID, AccountBestTradeMessage(bestTradeProfit, bestTradePosition));
    }



    /***************************************************************************************************************************
     * @brief     Notify on equity pass threshold
     **************************************************************************************************************************/
    void NotifyEquity(void)
    {
        SendMessage(chatID, AccountEquityMessage());
    }



private:
    long chatID;

/***************************************************************************************************************************
 * @brief     Find and return the number of open orders
 **************************************************************************************************************************/
    string OpenOrdersTotal(void)
    {
        int total = OrdersTotal();
        int count = 0;

        if (total <= 0)
        {
            return(StringConcatenate(NEWLINE, "Total Orders Outstanding: ", 0));
        }

        for (int i = 0; i < total; ++i)
        {
            OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

            if (OrderType() <= 1)
            {
                ++count;
            }
        }

        return StringConcatenate(NEWLINE, "Total Orders Outstanding: ", count);
    }



/***************************************************************************************************************************
 * @brief     Close a single trade.
 **************************************************************************************************************************/
    string CloseSingleTrade(int i)
    {
        int    OrderTicketValue = 0;
        double OrderLotsValue = 0;
        double ClosePrice = Ask;
        int    SlippageAllowed = 10;
        color  OrderCloseColour = Red;
        string retVal = "Order Closed Sucessfully";

        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            OrderTicketValue = OrderTicket();
            OrderLotsValue = OrderLots();

            if (OrderClose(OrderTicketValue, OrderLotsValue, ClosePrice, SlippageAllowed, OrderCloseColour))
            {
                retVal =
                    "Order Closed Sucessfully! The list will now have changed, please rerun /OpenOrdersList if more trades need closed.";
            }
            else
            {
                retVal = "Order Close Error, please check MT4 or try again";
            }
        }
        else
        {
            retVal = "Order Select Error, please try to close a valid position. /OpenOrdersList";
        }

        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Message structure for the single trade send
 **************************************************************************************************************************/
    string OrderSingleTrade(int i)
    {
        string retVal = "";

        if (OrdersTotal() <= 0)
        {
            return retVal;
        }

        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

        if (OrderType() > 1)
        {
            return retVal;
        }

        retVal = StringConcatenate(retVal, "--- OPEN ORDER ---");
        retVal = StringConcatenate(retVal, NEWLINE, "Ticket Position: ", i);
        retVal = StringConcatenate(retVal, NEWLINE, "Ticket: ", OrderTicket());
        retVal = StringConcatenate(retVal, NEWLINE, "Symbol: ", OrderSymbol());
        retVal = StringConcatenate(retVal, NEWLINE, "Type: ", DoubleToStr(OrderType()));
        retVal = StringConcatenate(retVal, NEWLINE, "Lots: ", DoubleToStr(OrderLots(), 2));
        retVal = StringConcatenate(retVal, NEWLINE, "Open Price: ", DoubleToStr(OrderOpenPrice(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Current Price: ", DoubleToStr(OrderClosePrice(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Current Profit: ", DoubleToStr(OrderProfit(), 2));
        retVal = StringConcatenate(retVal, NEWLINE, "Stop Loss: ", DoubleToStr(OrderStopLoss(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Take Profit: ", DoubleToStr(OrderTakeProfit(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Open Time: ", TimeToString(OrderOpenTime()));
        retVal = StringConcatenate(retVal, NEWLINE, "To close this trade the command is:", NEWLINE, "/CloseOpenOrder", i);
        retVal = StringConcatenate(retVal, NEWLINE, "------------------");

        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Get ticket information from historical ticket
 **************************************************************************************************************************/
    string OrderHistoryTicket(int i)
    {
        string retVal = "";

        if (OrdersHistoryTotal() <= 0)
        {
            return retVal;
        }

        OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);

        int orderType = OrderType();

        if (orderType > 1)
        {
            retVal = StringConcatenate(retVal, "--- ACCOUNT OPERATION ---");
            retVal = StringConcatenate(retVal, NEWLINE, "Total: ", DoubleToStr(OrderProfit(), 2), " ", AccountCurrency());
            retVal = StringConcatenate(retVal, NEWLINE, "------------------");
            return retVal;
        }

        retVal = StringConcatenate(retVal, "--- CLOSED ORDER ---");

        if (1 == orderType)
        {
            retVal = StringConcatenate(retVal, NEWLINE, "Order Type: OP_BUY");
        }
        else
        {
            retVal = StringConcatenate(retVal, NEWLINE, "Order Type: OP_SELL");
        }

        retVal = StringConcatenate(retVal, NEWLINE, "Ticket ID: ", i);
        retVal = StringConcatenate(retVal, NEWLINE, "Ticket: ", OrderTicket());
        retVal = StringConcatenate(retVal, NEWLINE, "Symbol: ", OrderSymbol());
        retVal = StringConcatenate(retVal, NEWLINE, "Type: ", OrderType());
        retVal = StringConcatenate(retVal, NEWLINE, "Lots: ", DoubleToStr(OrderLots(), 2));
        retVal = StringConcatenate(retVal, NEWLINE, "Open Price: ", DoubleToStr(OrderOpenPrice(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Current Price: ", DoubleToStr(OrderClosePrice(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Closed Profit: ", DoubleToStr(OrderProfit(), 2));
        retVal = StringConcatenate(retVal, NEWLINE, "Stop Loss: ", DoubleToStr(OrderStopLoss(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Take Profit: ", DoubleToStr(OrderTakeProfit(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Open Time: ", TimeToString(OrderOpenTime()));
        retVal = StringConcatenate(retVal, NEWLINE, "Close Time: ", TimeToString(OrderCloseTime()));
        retVal = StringConcatenate(retVal, NEWLINE, "Profit: ", DoubleToStr(OrderProfit(), 2), " ", AccountCurrency());
        retVal = StringConcatenate(retVal, NEWLINE, "------------------");

        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Get the total of historical tickets.
 **************************************************************************************************************************/
    string OrderHistoryTotal(void)
    {
        return StringConcatenate(NEWLINE, "Total Past Orders: ", OrdersHistoryTotal());
    }



/***************************************************************************************************************************
 * @brief     Get the account information as appropriate
 **************************************************************************************************************************/
    string AccountInfoReturn(void)
    {
        string retVal = "";

        retVal = StringConcatenate(retVal, NEWLINE, "Account Broker: ", AccountCompany());
        retVal = StringConcatenate(retVal, NEWLINE, "Account Server: ", AccountServer());
        retVal = StringConcatenate(retVal, NEWLINE, "Account Number: ", AccountNumber());
        retVal = StringConcatenate(retVal, NEWLINE, "Account Leverage: 1:", AccountLeverage());
        retVal = StringConcatenate(retVal, NEWLINE, "Account Stopout Level: ", AccountStopoutLevel(), "%");
        retVal = StringConcatenate(retVal, NEWLINE, "Account Server: ", AccountServer());
        retVal =
            StringConcatenate(retVal, NEWLINE, "Account Balance: ", DoubleToStr(AccountBalance(), 2), " ",
                              AccountCurrency());
        retVal = StringConcatenate(retVal, NEWLINE, "Account Equity: ", DoubleToStr(AccountEquity(), 2));
        retVal = StringConcatenate(retVal, NEWLINE, "Account Margin: ", DoubleToStr(AccountMargin(), 2), "%");
        retVal = StringConcatenate(retVal, NEWLINE, "Account FreeMargin: ", DoubleToStr(AccountFreeMargin(), 2), "%");
        retVal = StringConcatenate(retVal,
                                   NEWLINE,
                                   "Total Account Profit: ",
                                   DoubleToStr(AccountProfit(), 2),
                                   " ",
                                   AccountCurrency());

        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Get the account info for a 24 hour period
 **************************************************************************************************************************/
    string AccountInfoReturnSummary24Hour(void)
    {
        string retVal = "Telegram Controller EA";
        int    tradesDay;
        int    tradesWeek;
        double profitDay;
        double profitWeek;
        double outstandingTrades;

        CountNumberOrders(tradesDay, tradesWeek, profitDay, profitWeek, outstandingTrades);

        retVal = StringConcatenate(retVal, NEWLINE, "Daily Update, Account Summary", NEWLINE, "");
        retVal = StringConcatenate(retVal, NEWLINE, "Total Trades Day: ", tradesDay);
        retVal = StringConcatenate(retVal, NEWLINE, "Total Profit Day: ", DoubleToStr(profitDay, 2), " ", AccountCurrency());
        retVal = StringConcatenate(retVal, NEWLINE, "Total Trades Week: ", tradesWeek);
        retVal =
            StringConcatenate(retVal, NEWLINE, "Total Profit Week: ", DoubleToStr(profitWeek, 2), " ", AccountCurrency());
        retVal = StringConcatenate(retVal, NEWLINE, "Total Outstanding Trades: ", outstandingTrades);
        retVal = StringConcatenate(retVal,
                                   NEWLINE,
                                   "Account Balance: ",
                                   DoubleToStr(AccountInfoDouble(ACCOUNT_BALANCE), 2),
                                   " ",
                                   AccountCurrency());
        retVal = StringConcatenate(retVal, NEWLINE, "Account Equity: ", DoubleToStr(AccountInfoDouble(ACCOUNT_EQUITY), 2));
        retVal = StringConcatenate(retVal, NEWLINE, "Account Margin: ", DoubleToStr(AccountInfoDouble(ACCOUNT_MARGIN), 2));
        retVal =
            StringConcatenate(retVal, NEWLINE, "Account Margin Level: ",
                              DoubleToStr(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2));

        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Get data for a new order that has been processed.
 **************************************************************************************************************************/
    string AccountNewOpenOrder(int i)
    {
        string retVal = "";

        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

        int orderType = OrderType();

        retVal = StringConcatenate(retVal, "ALERT: NEW OPEN ORDER");

        if (1 == orderType)
        {
            retVal = StringConcatenate(retVal, NEWLINE, "Order Type: OP_BUY");
        }
        else
        {
            retVal = StringConcatenate(retVal, NEWLINE, "Order Type: OP_SELL");
        }

        retVal = StringConcatenate(retVal, NEWLINE, "Ticket ID: ", i);
        retVal = StringConcatenate(retVal, NEWLINE, "Ticket: ", OrderTicket());
        retVal = StringConcatenate(retVal, NEWLINE, "Symbol: ", OrderSymbol());
        retVal = StringConcatenate(retVal, NEWLINE, "Type: ", OrderType());
        retVal = StringConcatenate(retVal, NEWLINE, "Lots: ", DoubleToStr(OrderLots(), 2));
        retVal = StringConcatenate(retVal, NEWLINE, "Open Price: ", DoubleToStr(OrderOpenPrice(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Stop Loss: ", DoubleToStr(OrderStopLoss(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Take Profit: ", DoubleToStr(OrderTakeProfit(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Open Time: ", TimeToString(OrderOpenTime()));
        retVal = StringConcatenate(retVal, NEWLINE, "Profit: ", DoubleToStr(OrderProfit(), 2), " ", AccountCurrency());
        retVal = StringConcatenate(retVal, NEWLINE, "------------------");

        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Get data for an order that has now closed
 **************************************************************************************************************************/
    string AccountNewCloseOrder(int i)
    {
        string retVal = "";

        OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);

        int orderType = OrderType();

        retVal = StringConcatenate(retVal, "ALERT: NEW CLOSED ORDER");

        if (1 == orderType)
        {
            retVal = StringConcatenate(retVal, NEWLINE, "Order Type: OP_BUY");
        }
        else
        {
            retVal = StringConcatenate(retVal, NEWLINE, "Order Type: OP_SELL");
        }

        retVal = StringConcatenate(retVal, NEWLINE, "Ticket ID: ", i);
        retVal = StringConcatenate(retVal, NEWLINE, "Ticket: ", OrderTicket());
        retVal = StringConcatenate(retVal, NEWLINE, "Symbol: ", OrderSymbol());
        retVal = StringConcatenate(retVal, NEWLINE, "Type: ", OrderType());
        retVal = StringConcatenate(retVal, NEWLINE, "Lots: ", DoubleToStr(OrderLots(), 2));
        retVal = StringConcatenate(retVal, NEWLINE, "Open Price: ", DoubleToStr(OrderOpenPrice(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Current Price: ", DoubleToStr(OrderClosePrice(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Closed Profit: ", DoubleToStr(OrderProfit(), 2));
        retVal = StringConcatenate(retVal, NEWLINE, "Stop Loss: ", DoubleToStr(OrderStopLoss(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Take Profit: ", DoubleToStr(OrderTakeProfit(), 5));
        retVal = StringConcatenate(retVal, NEWLINE, "Open Time: ", TimeToString(OrderOpenTime()));
        retVal = StringConcatenate(retVal, NEWLINE, "Close Time: ", TimeToString(OrderCloseTime()));
        retVal = StringConcatenate(retVal, NEWLINE, "Profit: ", DoubleToStr(OrderProfit(), 2), " ", AccountCurrency());
        retVal = StringConcatenate(retVal, NEWLINE, "------------------");

        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Format an alert to be sent for margin drop below
 **************************************************************************************************************************/
    string AccountMarginMessage(void)
    {
        string retVal = "ALERT";
        retVal = StringConcatenate(retVal,
                                   NEWLINE,
                                   "ACCOUNT MARGIN DROPPED BELOW THRESHOLD",
                                   NEWLINE,
                                   "Account Margin: ",
                                   DoubleToStr(AccountInfoDouble(ACCOUNT_MARGIN), 2));
        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Format an alert to be sent for free margin drop below
 **************************************************************************************************************************/
    string AccountFreeMarginMessage(void)
    {
        string retVal = "ALERT";
        retVal = StringConcatenate(retVal,
                                   NEWLINE,
                                   "ACCOUNT FREE MARGIN DROPPED BELOW THRESHOLD",
                                   NEWLINE,
                                   "Account Free Margin: ",
                                   DoubleToStr(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2));
        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Format an alert to be sent for single trade worst drop below
 **************************************************************************************************************************/
    string AccountWorstTradeMessage(double worstTradeProfit, int worstTradePosition)
    {
        string retVal = "ALERT";
        retVal = StringConcatenate(retVal,
                                   NEWLINE,
                                   "ACCOUNT SINGLE TRADE DROPPED BELOW THRESHOLD",
                                   NEWLINE,
                                   "Account Worst Trade: ",
                                   DoubleToStr(worstTradeProfit, 2),
                                   NEWLINE,
                                   "Worst Trade Position: ",
                                   worstTradePosition,
                                   NEWLINE,
                                   " To Close Enter:",
                                   NEWLINE,
                                   "/CloseOpenOrder",
                                   worstTradePosition);
        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Format an alert to be sent for best trade above
 **************************************************************************************************************************/
    string AccountBestTradeMessage(double tradeProfit, int tradePosition)
    {
        string retVal = "ALERT";
        retVal = StringConcatenate(retVal,
                                   NEWLINE,
                                   "ACCOUNT SINGLE TRADE DROPPED BELOW THRESHOLD",
                                   NEWLINE,
                                   "Account Best Trade: ",
                                   DoubleToStr(tradeProfit, 2),
                                   NEWLINE,
                                   "Best Trade Position: ",
                                   tradePosition,
                                   NEWLINE,
                                   " To Close Enter:",
                                   NEWLINE,
                                   "/CloseOpenOrder",
                                   tradePosition);
        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Format an alert to be sent for equity drop below
 **************************************************************************************************************************/
    string AccountEquityMessage(void)
    {
        string retVal = "ALERT";
        retVal = StringConcatenate(retVal,
                                   NEWLINE,
                                   "ACCOUNT EQUITY DROPPED BELOW THRESHOLD",
                                   NEWLINE,
                                   "Account Equity: ",
                                   DoubleToStr(AccountInfoDouble(ACCOUNT_EQUITY), 2));
        return retVal;
    }



/***************************************************************************************************************************
 * @brief     Count the number of orders and return the summary
 **************************************************************************************************************************/
    void CountNumberOrders(int &nDay, int &nWeek, double &nProfitDay, double &nProfitWeek, double &nOutstanding)
    {
        datetime orderCloseTime = NULL;
        datetime currentTimeGMT = TimeGMT();
        datetime totalSecondsInDay = 24 * 60 * 60;
        datetime totalSecondsInWeek = 7 * 24 * 60 * 60;
        nDay = 0;
        nWeek = 0;
        nProfitDay = 0;
        nProfitWeek = 0;
        nOutstanding = 0;

        for (int pos = 0; pos < OrdersHistoryTotal(); ++pos)
        {
            if (OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY))
            {
                orderCloseTime = OrderCloseTime();

                if (orderCloseTime >= currentTimeGMT - totalSecondsInDay)
                {
                    ++nDay;
                    nProfitDay += OrderProfit() - OrderSwap() - OrderCommission();
                }

                if (orderCloseTime >= currentTimeGMT - totalSecondsInWeek)
                {
                    ++nWeek;
                    nProfitWeek += OrderProfit() - OrderSwap() - OrderCommission();
                }
            }
        }

        for (int pos = 0; pos < OrdersTotal(); ++pos)
        {
            if (OrderSelect(pos, SELECT_BY_POS))
            {
                orderCloseTime = OrderCloseTime();

                if (0 == orderCloseTime)
                {
                    nOutstanding += OrderProfit() - OrderSwap() - OrderCommission();
                }
            }
        }
    }



};
