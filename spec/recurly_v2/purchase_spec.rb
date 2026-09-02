require 'spec_helper'

describe Purchase do
  let(:plan_code) { 'plan_code' }
  let(:adjustments) { [{
    product_code: 'product_code',
    unit_amount_in_cents: 1_000,
    quantity: 1,
    custom_fields: [
      {
        name: 'field1',
        value: 'priceless'
      }
    ]
  }]}

  describe 'vertex_transaction_type attribute' do
    it 'should accept vertex_transaction_type as a purchase attribute' do
      purchase = Purchase.new(
        account: {account_code: 'account123'},
        vertex_transaction_type: 'rental',
        adjustments: adjustments
      )
      purchase.vertex_transaction_type.must_equal 'rental'
    end

    it 'should include vertex_transaction_type in XML output' do
      purchase = Purchase.new(
        account: {account_code: 'account123'},
        vertex_transaction_type: 'lease',
        adjustments: adjustments
      )
      xml = purchase.to_xml
      xml.must_include '<vertex_transaction_type>lease</vertex_transaction_type>'
    end

    it 'should accept adjustments with vertex_transaction_type within a purchase request' do
      purchase = Purchase.new(
        account: {account_code: 'account123'},
        adjustments: [
          {
            product_code: 'product_code',
            unit_amount_in_cents: 1_000,
            quantity: 1,
            vertex_transaction_type: 'lease'
          }
        ]
      )
      purchase.adjustments.first.vertex_transaction_type.must_equal 'lease'
    end

    it 'should include adjustment vertex_transaction_type in XML output' do
      purchase = Purchase.new(
        account: {account_code: 'account123'},
        adjustments: [
          {
            product_code: 'product_code',
            unit_amount_in_cents: 1_000,
            quantity: 1,
            vertex_transaction_type: 'rental'
          }
        ]
      )
      xml = purchase.to_xml
      xml.must_include '<vertex_transaction_type>rental</vertex_transaction_type>'
    end

    it 'should allow both purchase-level and adjustment-level vertex_transaction_type' do
      purchase = Purchase.new(
        account: {account_code: 'account123'},
        vertex_transaction_type: 'sale',
        adjustments: [
          {
            product_code: 'product_code_1',
            unit_amount_in_cents: 1_000,
            quantity: 1,
            vertex_transaction_type: 'lease'
          },
          {
            product_code: 'product_code_2',
            unit_amount_in_cents: 2_000,
            quantity: 1,
            vertex_transaction_type: 'rental'
          }
        ]
      )
      purchase.vertex_transaction_type.must_equal 'sale'
      purchase.adjustments[0].vertex_transaction_type.must_equal 'lease'
      purchase.adjustments[1].vertex_transaction_type.must_equal 'rental'
    end

    it 'should include both purchase and adjustment vertex_transaction_type in XML output' do
      purchase = Purchase.new(
        account: {account_code: 'account123'},
        vertex_transaction_type: 'sale',
        adjustments: [
          {
            product_code: 'product_code',
            unit_amount_in_cents: 1_000,
            quantity: 1,
            vertex_transaction_type: 'lease'
          }
        ]
      )
      xml = purchase.to_xml
      # Purchase-level vertex_transaction_type
      xml.must_match(/<purchase>.*<vertex_transaction_type>sale<\/vertex_transaction_type>.*<\/purchase>/m)
      # Adjustment-level vertex_transaction_type
      xml.must_match(/<adjustment>.*<vertex_transaction_type>lease<\/vertex_transaction_type>.*<\/adjustment>/m)
    end
  end

  let(:purchase) do
    Purchase.new(
      account: {account_code: 'account123'},
      transaction_type: 'moto',
      adjustments: adjustments,
      subscriptions: [
        {
          plan_code: plan_code,
          subscription_add_ons: [
            add_on_code: 'add_on_code',
            unit_amount_in_cents: 200
          ]
        }
      ],
      shipping_address_id: 1234,
      shipping_fees: [
        shipping_method_code: 'fedex_ground',
        shipping_amount_in_cents: 999
      ],
      shipping_address:  {
        nickname: "Work",
        first_name: "Verena",
        last_name: "Example",
        company: "Recurly Inc.",
        phone: "555-555-5555",
        email: "verena@example.com",
        address1: "400 Alabama St.",
        city: "San Francisco",
        state: "CA",
        zip: "94110",
        country: "US"
      }
    )
  end
  let(:purchase_with_net_terms_type) do
    Purchase.new(
      account: {account_code: 'account123'},
      net_terms: 30,
      net_terms_type: 'eom',
      transaction_type: 'moto',
      adjustments: adjustments,
      subscriptions: [
        {
          plan_code: plan_code,
          subscription_add_ons: [
            add_on_code: 'add_on_code',
            unit_amount_in_cents: 200
          ]
        }
      ],
      shipping_address_id: 1234,
      shipping_fees: [
        shipping_method_code: 'fedex_ground',
        shipping_amount_in_cents: 999
      ],
      shipping_address:  {
        nickname: "Work",
        first_name: "Verena",
        last_name: "Example",
        company: "RecurlyV2 Inc.",
        phone: "555-555-5555",
        email: "verena@example.com",
        address1: "400 Alabama St.",
        city: "San Francisco",
        state: "CA",
        zip: "94110",
        country: "US"
      }
    )
  end

  describe 'Purchase.invoice!' do
    it 'should return an invoice_collection when valid' do
      stub_api_request(:post, 'purchases', 'purchases/invoice-201')
      collection = Purchase.invoice!(purchase)
      collection.charge_invoice.must_be_instance_of Invoice
      shipping_address = collection.charge_invoice.line_items.first.shipping_address
      shipping_address.must_be_instance_of ShippingAddress
    end

    it 'should contain action result attribute on response' do
      stub_api_request(:post, 'purchases', 'purchases/invoice-with-action-result-201')
      collection = Purchase.invoice!(purchase)
      expect(collection.charge_invoice.transactions.first.action_result).must_equal('example')
    end

    it 'the first ramp interval unit amount is reflected in these expected attributes' do
      stub_api_request(:post, 'purchases', 'purchases/invoice-with-ramp-pricing-201')
      collection = Purchase.invoice!(purchase)
      charge_invoice = collection.charge_invoice

      charge_invoice.total_in_cents.must_equal 7000
      charge_invoice.subtotal_before_discount_in_cents.must_equal 7000
      charge_invoice.subtotal_in_cents.must_equal 7000
      charge_invoice.refundable_total_in_cents.must_equal 7000

      charge_invoice.line_items.first.unit_amount_in_cents.must_equal 7000
      charge_invoice.line_items.first.refundable_total_in_cents.must_equal 7000
      charge_invoice.line_items.first.total_in_cents.must_equal 7000

      charge_invoice.transactions.first.amount_in_cents.must_equal 7000
    end

    it 'should return an invoice_collection with net_terms_type when valid' do
      stub_api_request(:post, 'purchases', 'purchases/invoice-with-eom-net-terms-201')
      collection = Purchase.invoice!(purchase_with_net_terms_type)
      charge_invoice = collection.charge_invoice

      charge_invoice.total_in_cents.must_equal 7000
      charge_invoice.net_terms.must_equal 30
      charge_invoice.net_terms_type.must_equal 'eom'
    end

    it 'should raise an Invalid error when data is invalid' do
      stub_api_request(:post, 'purchases', 'purchases/invoice-422')
      # ensure error is raised
      proc { Purchase.invoice!(purchase) }.must_raise Resource::Invalid
      # ensure error details are mapped back
      purchase.adjustments.first.errors['unit_amount_in_cents'].must_equal ['is not a number']
      purchase.subscriptions.first.errors['subscription_add_ons'].must_equal ['is invalid']
    end

    it 'should raise a Transaction::Error error when transaction fails' do
      stub_api_request(:post, 'purchases', 'purchases/invoice-declined-422')
      proc { Purchase.invoice!(purchase) }.must_raise Transaction::DeclinedError
    end

    it 'should return custom fields for an adjustment on a purchase that has custom fields' do
      stub_api_request(:post, 'purchases', 'purchases/invoice-422')

      purchase.adjustments.first.custom_fields.first.name.must_equal 'field1'
      purchase.adjustments.first.custom_fields.first.value.must_equal 'priceless'
    end

    describe 'with RevRec feature flag' do
      let(:adjustments) { [{
          product_code: 'product_code',
          unit_amount_in_cents: 1_000,
          quantity: 1,
          liability_gl_account_id: 'ad8h3layw',
          revenue_gl_account_id: 'ydu5owk',
          performance_obligation_id: '5',
        }]
      }
      it 'should return RevRec details for an adjustment on a purchase that has RevRec details' do
        stub_api_request(:post, 'purchases', 'purchases/invoice-201-with-revrec')
        collection = Purchase.invoice!(purchase)
        adjustment_list = collection.charge_invoice.line_items
        adjustment_list.first.liability_gl_account_code.must_equal 'liability_gla'
        adjustment_list.first.revenue_gl_account_code.must_equal 'revenue_gla'
        adjustment_list.first.performance_obligation_id.must_equal '5'
      end
    end
  end

  describe 'Purchase.preview!' do
    it 'should return a preview invoice when valid' do
      stub_api_request(:post, 'purchases/preview', 'purchases/preview-201')
      preview_collection = Purchase.preview!(purchase)
      preview_collection.charge_invoice.must_be_instance_of Invoice
    end

    it 'should return a preview invoice with net_terms_type when valid' do
      stub_api_request(:post, 'purchases/preview', 'purchases/preview-201-with-eom-net-terms')
      preview_collection = Purchase.preview!(purchase_with_net_terms_type)
      preview_collection.charge_invoice.must_be_instance_of Invoice
      preview_collection.charge_invoice.net_terms.must_equal 30
      preview_collection.charge_invoice.net_terms_type.must_equal 'eom'
    end

    it 'the first ramp interval unit amount is reflected in these expected attributes' do
      stub_api_request(:post, 'purchases/preview', 'purchases/preview-with-ramp-pricing-201')
      collection = Purchase.preview!(purchase)
      charge_invoice = collection.charge_invoice

      charge_invoice.total_in_cents.must_equal 7000
      charge_invoice.subtotal_before_discount_in_cents.must_equal 7000
      charge_invoice.subtotal_in_cents.must_equal 7000
      charge_invoice.refundable_total_in_cents.must_equal 7000

      charge_invoice.line_items.first.unit_amount_in_cents.must_equal 7000
      charge_invoice.line_items.first.refundable_total_in_cents.must_equal 7000
      charge_invoice.line_items.first.total_in_cents.must_equal 7000
    end

    it 'should raise an Invalid error when data is invalid' do
      stub_api_request(:post, 'purchases/preview', 'purchases/invoice-422')
      # ensure error is raised
      proc {Purchase.preview!(purchase)}.must_raise Resource::Invalid
      # ensure error details are mapped back
      purchase.adjustments.first.errors['unit_amount_in_cents'].must_equal ['is not a number']
    end

    describe 'with RevRec feature flag' do
      let(:adjustments) { [{
          product_code: 'product_code',
          unit_amount_in_cents: 1_000,
          quantity: 1,
          liability_gl_account_id: 'ad8h3layw',
          revenue_gl_account_id: 'ydu5owk',
          performance_obligation_id: '5',
        }]
      }
      it 'should return RevRec details for an adjustment on a purchase that has RevRec details' do
        stub_api_request(:post, 'purchases/preview', 'purchases/preview-201-with-revrec')
        preview_collection = Purchase.preview!(purchase)
        adjustment_list = preview_collection.charge_invoice.line_items
        adjustment_list.first.liability_gl_account_code.must_equal 'liability_gla'
        adjustment_list.first.revenue_gl_account_code.must_equal 'revenue_gla'
        adjustment_list.first.performance_obligation_id.must_equal '5'
      end
    end
  end

  describe 'Purchase.authorize!' do
    it 'should return an authorized invoice when valid' do
      stub_api_request(:post, 'purchases/authorize', 'purchases/preview-201')
      authorized_collection = Purchase.authorize!(purchase)
      authorized_invoice = authorized_collection.charge_invoice
      authorized_invoice.must_be_instance_of Invoice
    end

    it 'the first ramp interval unit amount is reflected in these expected attributes' do
      stub_api_request(:post, 'purchases/authorize', 'purchases/authorize-with-ramp-pricing-201')
      collection = Purchase.authorize!(purchase)
      charge_invoice = collection.charge_invoice

      charge_invoice.total_in_cents.must_equal 7000
      charge_invoice.subtotal_before_discount_in_cents.must_equal 7000
      charge_invoice.subtotal_in_cents.must_equal 7000
      charge_invoice.refundable_total_in_cents.must_equal 7000

      charge_invoice.line_items.first.unit_amount_in_cents.must_equal 7000
      charge_invoice.line_items.first.refundable_total_in_cents.must_equal 7000
      charge_invoice.line_items.first.total_in_cents.must_equal 7000

      charge_invoice.transactions.first.amount_in_cents.must_equal 7000
    end

    it 'should raise an Invalid error when data is invalid' do
      stub_api_request(:post, 'purchases/authorize', 'purchases/invoice-422')
      # ensure error is raised
      proc {Purchase.authorize!(purchase)}.must_raise Resource::Invalid
      # ensure error details are mapped back
      purchase.adjustments.first.errors['unit_amount_in_cents'].must_equal ['is not a number']
    end

    describe 'with RevRec feature flag' do
      let(:adjustments) { [{
          product_code: 'product_code',
          unit_amount_in_cents: 1_000,
          quantity: 1,
          liability_gl_account_id: 'ad8h3layw',
          revenue_gl_account_id: 'ydu5owk',
          performance_obligation_id: '5',
        }]
      }
      it 'should return RevRec details for an adjustment on a purchase that has RevRec details' do
        stub_api_request(:post, 'purchases/authorize', 'purchases/preview-201-with-revrec')
        authorized_collection = Purchase.authorize!(purchase)
        adjustment_list = authorized_collection.charge_invoice.line_items
        adjustment_list.first.liability_gl_account_code.must_equal 'liability_gla'
        adjustment_list.first.revenue_gl_account_code.must_equal 'revenue_gla'
        adjustment_list.first.performance_obligation_id.must_equal '5'
      end
    end
  end

  describe 'Purchase.pending!' do
    it 'should return an authorized invoice when valid' do
      stub_api_request(:post, 'purchases/pending', 'purchases/preview-201')
      authorized_collection = Purchase.pending!(purchase)
      authorized_invoice = authorized_collection.charge_invoice
      authorized_invoice.must_be_instance_of Invoice
    end

    it 'the first ramp interval unit amount is reflected in these expected attributes' do
      stub_api_request(:post, 'purchases/pending', 'purchases/pending-with-ramp-pricing-201')
      collection = Purchase.pending!(purchase)
      charge_invoice = collection.charge_invoice

      charge_invoice.total_in_cents.must_equal 7000
      charge_invoice.subtotal_before_discount_in_cents.must_equal 7000
      charge_invoice.subtotal_in_cents.must_equal 7000
      charge_invoice.refundable_total_in_cents.must_equal 7000

      charge_invoice.line_items.first.unit_amount_in_cents.must_equal 7000
      charge_invoice.line_items.first.refundable_total_in_cents.must_equal 7000
      charge_invoice.line_items.first.total_in_cents.must_equal 7000
    end

    it 'should raise an Invalid error when data is invalid' do
      stub_api_request(:post, 'purchases/pending', 'purchases/invoice-422')
      # ensure error is raised
      proc { Purchase.pending!(purchase) }.must_raise Resource::Invalid
      # ensure error details are mapped back
      purchase.adjustments.first.errors['unit_amount_in_cents'].must_equal ['is not a number']
    end

    describe 'with RevRec feature flag' do
      let(:adjustments) { [{
          product_code: 'product_code',
          unit_amount_in_cents: 1_000,
          quantity: 1,
          liability_gl_account_id: 'ad8h3layw',
          revenue_gl_account_id: 'ydu5owk',
          performance_obligation_id: '5',
        }]
      }
      it 'should return RevRec details for an adjustment on a purchase that has RevRec details' do
        stub_api_request(:post, 'purchases/pending', 'purchases/preview-201-with-revrec')
        pending_collection = Purchase.pending!(purchase)
        adjustment_list = pending_collection.charge_invoice.line_items
        adjustment_list.first.liability_gl_account_code.must_equal 'liability_gla'
        adjustment_list.first.revenue_gl_account_code.must_equal 'revenue_gla'
        adjustment_list.first.performance_obligation_id.must_equal '5'
      end
    end
  end

  describe "Purchase.capture!" do
    it "should return a captured invoice collection when valid" do
      tr_uuid = 'abcd1234'
      stub_api_request(:post, "purchases/transaction-uuid-#{tr_uuid}/capture", 'purchases/preview-201')
      captured_collection = Purchase.capture!(tr_uuid)
      captured_invoice = captured_collection.charge_invoice
      captured_invoice.must_be_instance_of Invoice
    end
    it "should raise an Invalid error when data is invalid" do
      tr_uuid = 'abcd1234'
      stub_api_request(:post, "purchases/transaction-uuid-#{tr_uuid}/capture", 'purchases/invoice-422')
      # ensure error is raised
      proc {Purchase.capture!(tr_uuid)}.must_raise Resource::Invalid
    end
  end

  describe "Purchase.cancel!" do
    it "should return a canceled invoice collection when valid" do
      tr_uuid = 'abcd1234'
      stub_api_request(:post, "purchases/transaction-uuid-#{tr_uuid}/cancel", 'purchases/preview-201')
      canceled_collection = Purchase.cancel!(tr_uuid)
      canceled_invoice = canceled_collection.charge_invoice
      canceled_invoice.must_be_instance_of Invoice
    end
    it "should raise an Invalid error when data is invalid" do
      tr_uuid = 'abcd1234'
      stub_api_request(:post, "purchases/transaction-uuid-#{tr_uuid}/cancel", 'purchases/invoice-422')
      # ensure error is raised
      proc {Purchase.cancel!(tr_uuid)}.must_raise Resource::Invalid
    end
  end
end
