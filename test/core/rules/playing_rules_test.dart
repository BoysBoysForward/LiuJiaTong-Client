import 'package:flutter_test/flutter_test.dart';
import 'package:liujiatong/core/models/card.dart';
import 'package:liujiatong/core/rules/playing_rules.dart';

void main() {
  group('playing_rules', () {
    test('单张合法', () {
      final r = judgeAndTransformCards([14]);
      expect(r.type, CardType.single);
      expect(r.keyCard, 14);
    });

    test('对子合法', () {
      final r = judgeAndTransformCards([14, 14]);
      expect(r.type, CardType.pair);
      expect(r.keyCard, 14);
    });

    test('三张合法', () {
      final r = judgeAndTransformCards([10, 10, 10]);
      expect(r.type, CardType.triple);
      expect(r.keyCard, 10);
    });

    test('非法牌型', () {
      final r = judgeAndTransformCards([3, 5, 7]);
      expect(r.type, CardType.illegalType);
    });

    test('firstInputLegal', () {
      expect(firstInputLegal([14]), true);
      expect(firstInputLegal([3, 5, 7]), false);
    });

    test('validateUserInput 首出单张', () {
      final hand = [Card(Suits.spade, 14)];
      final r = validateUserInput([14], hand, null);
      expect(r.legal, true);
      expect(r.score, 0);
    });

    test('validateUserInput 跳过', () {
      final r = validateUserInput([0], [], [Card(Suits.spade, 5)]);
      expect(r.legal, true);
      final r2 = validateUserInput([0], [], null);
      expect(r2.legal, false);
    });

    test('validateUserSelectedCards', () {
      final selected = [Card(Suits.spade, 14), Card(Suits.heart, 14)];
      final hand = [Card(Suits.spade, 14), Card(Suits.heart, 14), Card(Suits.club, 5)];
      expect(validateUserSelectedCards(selected, hand, null), true);
    });

    test('顺子 5 张合法', () {
      final cards = [11, 10, 9, 8, 7]; // J-10-9-8-7
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.straight);
      expect(r.keyCard, 11);
    });

    test('普通炸弹 4 张', () {
      final r = judgeAndTransformCards([14, 14, 14, 14]);
      expect(r.type, CardType.normalBomb);
      expect(r.keyCard, 14);
    });

    // ====== 基本九种牌型 ======

    test('三带二合法', () {
      final r = judgeAndTransformCards([10, 10, 10, 9, 9]);
      expect(r.type, CardType.triplePair);
      expect(r.keyCard, 10);
    });

    test('连对合法（普通连对）', () {
      final cards = [7, 7, 8, 8, 9, 9]; // 77 88 99
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.straightPairs);
      expect(r.keyCard, 9);
    });

    test('最小连对 AA22 合法', () {
      final cards = [14, 14, 15, 15]; // AA22
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.straightPairs);
      // AA22 的 keyCard 约定为 1（见实现）
      expect(r.keyCard, 1);
    });

    test('连三合法（连续三张）', () {
      final cards = [8, 8, 8, 9, 9, 9]; // 888 999
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.straightTriples);
      expect(r.keyCard, 9);
    });

    test('飞机合法（无赖子特殊形态 4455666777)', () {
      final cards = [4, 4, 5, 5, 6, 6, 6, 7, 7, 7]; // 44 55 6 6 6 7 7 7
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.flight);
      expect(r.keyCard, 7);
    });

    // ====== 含一张赖子的牌型 ======

    test('一张赖子与单张组成对子', () {
      final cards = [16, 14]; // 小王 + A
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.pair);
      // keyCard 为实际点数 A
      expect(r.keyCard, 14);
    });

    test('一张赖子与对子组成三张', () {
      final cards = [16, 10, 10]; // 小王 + 10 10
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.triple);
      expect(r.keyCard, 10);
    });

    test('一张赖子补成顺子', () {
      // 10 J Q K + 小王 = 10 J Q K A
      final cards = [16, 13, 12, 11, 10];
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.straight);
      // keyCard 为顺子最大牌 A(14)
      expect(r.keyCard, 14);
    });

    test('一张赖子补成连对', () {
      // 77 88 + 小王 99-> 77 88 99
      final cards = [16, 9, 8, 8, 7, 7];
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.straightPairs);
    });

    test('一张赖子补成三带二', () {
      // 10 10 10 + 9 + 小王 -> 10 10 10 9 9
      final cards = [16, 9, 10, 10, 10];
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.triplePair);
      expect(r.keyCard, 10);
    });

    // ====== 含多张赖子的炸弹与优先级 ======

    test('普通炸弹之间比较：5 张炸弹大于 4 张炸弹', () {
      final last = [13, 13, 13, 13]; // 4 张 K
      final next = [14, 14, 14, 14, 14]; // 5 张 A
      last.sort((a, b) => b.compareTo(a));
      next.sort((a, b) => b.compareTo(a));
      final ok = ifNotFirstInputLegal(next, last);
      expect(ok, isTrue);
    });

    test('普通炸弹之间比较：4 张 A 大于 4 张 K', () {
      final last = [13, 13, 13, 13]; // 4 张 K
      final next = [14, 14, 14, 14]; // 4 张 A
      last.sort((a, b) => b.compareTo(a));
      next.sort((a, b) => b.compareTo(a));
      final ok = ifNotFirstInputLegal(next, last);
      expect(ok, isTrue);
    });

    test('小王炸弹不能压 4~8 张普通炸弹', () {
      final last = [14, 14, 14, 14]; // 4 张 A
      final next = [16, 16, 16, 16]; // 4 张小王
      last.sort((a, b) => b.compareTo(a));
      next.sort((a, b) => b.compareTo(a));
      final ok = ifNotFirstInputLegal(next, last);
      expect(ok, isFalse);
    });

    test('9 张普通炸弹可以压小王炸弹', () {
      final last = [16, 16, 16, 16]; // 小王炸弹
      final next = List<int>.filled(9, 14); // 9 张 A
      last.sort((a, b) => b.compareTo(a));
      next.sort((a, b) => b.compareTo(a));
      final ok = ifNotFirstInputLegal(next, last);
      expect(ok, isTrue);
    });

    test('大王炸弹不能压 4~8 张普通炸弹', () {
      final last = [14, 14, 14, 14]; // 4 张 A
      final next = [17, 17, 17, 17]; // 4 张大王
      last.sort((a, b) => b.compareTo(a));
      next.sort((a, b) => b.compareTo(a));
      final ok = ifNotFirstInputLegal(next, last);
      expect(ok, isFalse);
    });

    test('9 张普通炸弹可以压大王炸弹', () {
      final last = [17, 17, 17, 17]; // 大王炸弹
      final next = List<int>.filled(9, 14); // 9 张 A
      last.sort((a, b) => b.compareTo(a));
      next.sort((a, b) => b.compareTo(a));
      final ok = ifNotFirstInputLegal(next, last);
      expect(ok, isTrue);
    });

    test('大王炸弹可以压小王炸弹', () {
      final last = [16, 16, 16, 16]; // 小王炸弹
      final next = [17, 17, 17, 17]; // 大王炸弹
      last.sort((a, b) => b.compareTo(a));
      next.sort((a, b) => b.compareTo(a));
      final ok = ifNotFirstInputLegal(next, last);
      expect(ok, isTrue);
    });

    test('小王炸弹不能压大王炸弹', () {
      final last = [17, 17, 17, 17]; // 大王炸弹
      final next = [16, 16, 16, 16]; // 小王炸弹
      last.sort((a, b) => b.compareTo(a));
      next.sort((a, b) => b.compareTo(a));
      final ok = ifNotFirstInputLegal(next, last);
      expect(ok, isFalse);
    });

    test('带赖子的普通炸弹 keyCard 为普通牌点数', () {
      // 888 + 两张小王，按规则应视为 5 张 8 的炸弹，keyCard = 8
      final cards = [16, 16, 8, 8, 8];
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.normalBomb);
      expect(r.keyCard, 8);
    });

    // ====== 边界牌型测试 ======

    test('最小顺子 A2345 合法', () {
      final cards = [14, 5, 4, 3, 2]; // A2345
      cards.sort((a, b) => b.compareTo(a));
      final r = judgeAndTransformCards(cards);
      expect(r.type, CardType.straight);
      expect(r.keyCard, 5);
    });

    test('非法乱牌仍为 illegalType', () {
      final r = judgeAndTransformCards([3, 4, 6, 7, 9]);
      expect(r.type, CardType.illegalType);
    });

    test('ifEnoughCard 手牌不足返回 false', () {
      final hand = [Card(Suits.spade, 14)];
      final result = ifEnoughCard([14, 14], hand);
      expect(result.enough, false);
      expect(result.score, 0);
    });

    test('validateUserInput 返回正确分数', () {
      final hand = [
        Card(Suits.spade, 5),
        Card(Suits.heart, 5),
        Card(Suits.club, 10),
      ];
      final r = validateUserInput([5, 10], hand, null);
      expect(r.legal, false); // 两张不构成合法牌型
      final r2 = validateUserInput([5], hand, null);
      expect(r2.legal, true);
      expect(r2.score, 5);
    });
  });
}
