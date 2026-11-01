module API
  module V1
    class PayslipsSerializer
      def initialize(payslip)
        @payslip = payslip
      end

      def serialize
        {
          id: payslip.id,
          employee_id: payslip.employee_id,
          payslip_number: payslip.payslip_number,
          period_start: payslip.period_start,
          period_end: payslip.period_end,
          pay_date: payslip.pay_date,
          gross_pay: MoneyFormat.format_money(payslip.gross_pay),
          deductions: MoneyFormat.format_money(payslip.deductions),
          net_pay: MoneyFormat.format_money(payslip.net_pay),
          status: payslip.status,
          currency: MoneyFormat.currency(payslip.currency),
          created_at: payslip.created_at,
          updated_at: payslip.updated_at
        }
      end

      private

      attr_reader :payslip
    end
  end
end
