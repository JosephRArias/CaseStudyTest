import { LightningElement, api, wire, track } from "lwc";
import getProductEntries from "@salesforce/apex/OpportunityProductController.getProductEntries";
import addOpportunityProduct from "@salesforce/apex/OpportunityProductController.addOpportunityProduct";
import populateDataTable from "@salesforce/apex/OpportunityProductController.populateDataTable";
import updateRecords from "@salesforce/apex/OpportunityProductController.updateRecords";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const columns = [
  {
    label: "Product Name",
    fieldName: "Name",
    type: "text",
    editable: false
  },
  {
    label: "Unit Price",
    fieldName: "UnitPrice",
    type: "currency",
    editable: false
  }
];
const selectedColumns = [
  {
    label: "Product Name",
    fieldName: "Name",
    type: "text",
    editable: false
  },
  { label: "Quantity", fieldName: "Quantity", type: "number", editable: true },
  {
    label: "Discount",
    fieldName: "Discount",
    type: "percent",
    typeAttributes: {
      step: "0.01",
      minimumFractionDigits: "2",
      maximumFractionDigits: "3"
    },
    editable: true
  },
  {
    label: "Total Price",
    fieldName: "TotalPrice",
    type: "currency",
    editable: false
  }
];
export default class OpportunityLineLWC extends LightningElement {
  @api recordId;
  @track pricebookEntries = [];
  @track addedProducts = [];
  @track products;
  columns = columns;
  selectedColumns = selectedColumns;
  @track selectedProducts = [];
  draftValues = [];
  _wiredResult;
  _wiredSelect;
  error;
  @wire(getProductEntries, { pricebookId: "01sbm000004JhLWAA0" })
  wiredSelect(result) {
    this._wiredSelect = result;
    if (result.data) {
      this.products = result.data;
    } else if (result.error) {
      this.error = result.error;
      this.products = undefined;
    }
  }
  @wire(populateDataTable, { opportunityId: "$recordId" })
  wiredProducts(result) {
    this._wiredResult = result;
    if (result.data) {
      this.addedProducts = result.data.map((entry) => {
        return {
          ...entry,
          Name: entry.PricebookEntry.Name
        };
      });
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.addedProducts = undefined;
    }
  }
  handleRowSelection(event) {
    console.log("Selected Rows:", event.detail.selectedRows);
    this.selectedProducts = event.detail.selectedRows;
  }

  moveSelectedProducts() {
    const productIds = this.selectedProducts.map((row) => row.Product2Id);
    addOpportunityProduct({
      opportunityId: this.recordId,
      productIds: productIds
    })
      .then(() => {
        this.products = this.products.filter(
          (product) => !productIds.includes(product.Product2Id)
        );

        // Handle success
        console.log("Opportunity Line Item added");
        refreshApex(this._wiredResult);
      })
      .catch((error) => {
        console.error("Error adding Opportunity Line Item:", error);
      });
  }
  async updateSelectedRows(event) {
    this.draftValues = event.detail.draftValues;
    console.log(this.draftValues);
    updateRecords({ opportunityLineData: this.draftValues })
      .then((result) => {
        console.log("Result: ", result);
        this.draftValues = [];
        refreshApex(this._wiredResult);
      })
      .catch((error) => {
        const errorMessage = error.body.message;

        this.showToast(
          "Error",
          "Error updating records: " + errorMessage,
          "error"
        );

        this.draftValues = [...this.draftValues];
      });
  }
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}
