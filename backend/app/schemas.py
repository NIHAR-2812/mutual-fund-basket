from typing import Literal
from pydantic import BaseModel, Field

class AddFund(BaseModel):
    fundId: int = Field(gt=0)

class Fund(BaseModel):
    id: int
    name: str
    category: Literal['Equity', 'Debt', 'Hybrid']
    three_year_return: float
    expense_ratio: float
    risk_level: Literal['Low', 'Moderate', 'High']
