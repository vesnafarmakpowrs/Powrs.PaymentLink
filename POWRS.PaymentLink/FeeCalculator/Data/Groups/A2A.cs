﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace POWRS.PaymentLink.FeeCalculator.Data
{
    public class A2A : BaseFeeCalculatorModel
    {
        public A2A()
        {
            base.ShowGroup = false;
        }

        private decimal averageAmount;
        private decimal saved;

        public decimal AverageAmount { get => averageAmount; set => averageAmount = value; }
        public decimal Saved { get => saved; set => saved = value; }
    }
}
