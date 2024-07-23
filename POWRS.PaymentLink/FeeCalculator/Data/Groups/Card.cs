using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace POWRS.PaymentLink.FeeCalculator.Data
{
    public class Card: BaseFeeCalculatorModel
    {
        public Card()
        {
            base.ShowGroup = true;
        }

        private decimal averageAmount;
        private decimal saved;

        public decimal AverageAmount { get => averageAmount; set => averageAmount = value; }
        public decimal Saved { get => saved; set => saved = value; }
    }
}
