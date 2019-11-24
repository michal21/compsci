from django.db import models
from django.contrib.auth.models import User
from django.core.validators import RegexValidator

# Create your models here.

class Transfer(models.Model):
    to = models.CharField(validators=[RegexValidator(regex=r'^\d{26}$', message="Invalid account number")], null=False, max_length=26)
    user = models.ForeignKey(User, on_delete=models.PROTECT, editable=False)
    title = models.CharField(max_length=100, blank=False, null=False)
    amnt = models.DecimalField(max_digits=6, decimal_places=2)
    accpt = models.BooleanField(default=False)

