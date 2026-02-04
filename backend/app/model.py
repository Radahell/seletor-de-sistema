# Adicione junto com suas importações de SQLAlchemy
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func

# Mapeamento da tabela existente
class SuperAdmin(Base):
    __tablename__ = 'super_admins'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())