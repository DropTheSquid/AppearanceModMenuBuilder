using LegendaryExplorerCore.Coalesced;

namespace AppearanceModMenuBuilder.LE1.Models
{
    public interface ICoalesceValue
    {
        string OutputValue();

        CoalesceValue ToCoalesceValue(CoalesceParseAction type)
        {
            return new CoalesceValue(OutputValue(), type);
        }
    }

    public record class IntCoalesceValue(int Value) : ICoalesceValue
    {
        public string OutputValue()
        {
            return Value.ToString();
        }
    }

    public record class StringCoalesceValue(string Value) : ICoalesceValue
    {
        public string OutputValue()
        {
            return @$"""{Value}""";
        }
    }

    public record class BoolCoalesceValue(bool Value) : ICoalesceValue
    {
        public string OutputValue()
        {
            return Value.ToString();
        }
    }

    public record class StringArrayCoalesceValue(string[] Value) : ICoalesceValue
    {
        public string OutputValue()
        {
            var items = new List<string>();
            foreach (var item in Value)
            {
                items.Add(@$"""{item}""");
            }

            return $"({string.Join(",", items)})";
        }
    }

    public class StructCoalesceValue : Dictionary<string, ICoalesceValue>, ICoalesceValue
    {
        public string OutputValue()
        {
            var items = new List<string>();
            foreach (var item in this)
            {
                items.Add(item.Key + "=" + item.Value.OutputValue());
            }

            return $"({string.Join(",", items)})";
        }
    }
}
