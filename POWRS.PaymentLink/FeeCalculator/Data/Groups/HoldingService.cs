﻿using POWRS.PaymentLink.FeeCalculator.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace POWRS.PaymentLink.FeeCalculator.Data
{
    public class HoldingService : BaseFeeCalculatorModel
    {
        public HoldingService()
        {
            base.ShowGroup = false;
        }

        private CostPay costPay;
        private decimal kickBackPerTransaction;
        private decimal incomeSummary;

        public CostPay CostPay { get => costPay; set => costPay = value; }
        public decimal KickBackPerTransaction { get => kickBackPerTransaction; set => kickBackPerTransaction = value; }
        public decimal IncomeSummary { get => incomeSummary; set => incomeSummary = value; }
    }
}
